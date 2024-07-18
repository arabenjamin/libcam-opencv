#include <opencv2/opencv.hpp>
#include <libcamera/libcamera.h>
#include <iostream>
#include <chrono>
#include <thread>

class CameraHandler
{
public:
    CameraHandler(std::shared_ptr<libcamera::Camera> camera)
        : camera_(camera), quit_(false)
    {
        camera_->requestCompleted.connect(this, &CameraHandler::requestComplete);
    }

    void requestComplete(libcamera::Request *request)
    {
        if (request->status() == libcamera::Request::Status::RequestComplete) {
            const libcamera::FrameBuffer *buffer = request->buffers().begin()->second;
            
            // Use the stored streamConfig_ instead of trying to access it from the request
            if (frame_.empty()) {
                frame_ = cv::Mat(cv::Size(streamConfig_.size.width, streamConfig_.size.height), CV_8UC3);
            }

            libcamera::Span<uint8_t> span = mappedBuffers_[buffer];
            memcpy(frame_.data, span.data(), span.size());

            cv::imshow("Frame", frame_);
            if (cv::waitKey(1) == 'q')
                quit_ = true;
        }
        request->reuse(libcamera::Request::ReuseBuffers);
        camera_->queueRequest(request);
    }

    void setFrame(cv::Mat frame) { frame_ = frame; }
    bool shouldQuit() const { return quit_; }

private:
    std::shared_ptr<libcamera::Camera> camera_;
    libcamera::StreamConfiguration streamConfig_; // Store the stream configuration here
    cv::Mat frame_;
    bool quit_;
    std::unordered_map<const libcamera::FrameBuffer *, libcamera::Span<uint8_t>> mappedBuffers_;
};

int main() {
    libcamera::CameraManager manager;

    manager.start();

    auto cameras = manager.cameras();
    if (cameras.empty()) {
        std::cerr << "No cameras available" << std::endl;
        return -1;
    }

    auto camera = cameras[0];
    camera->acquire();

    std::unique_ptr<libcamera::CameraConfiguration> config = camera->generateConfiguration({libcamera::StreamRole::Viewfinder});
    libcamera::StreamConfiguration &streamConfig = config->at(0);
    streamConfig.pixelFormat = libcamera::formats::RGB888;
    streamConfig.size.width = 640;
    streamConfig.size.height = 480;
    //streamConfig.bufferCount = 4;

    config->validate();
    auto status = camera->configure(config.get());
    if (status != 0) {
        std::cerr << "Failed to configure camera" << std::endl;
        return -1;
    }

    CameraHandler handler(camera);

    cv::Mat frame(streamConfig.size.height, streamConfig.size.width, CV_8UC3);
    handler.setFrame(frame);

    libcamera::FrameBufferAllocator *allocator = new libcamera::FrameBufferAllocator(camera);
    allocator->allocate(streamConfig.stream());

    std::vector<std::unique_ptr<libcamera::Request>> requests;
    for (const auto &buffer : allocator->buffers(streamConfig.stream())) {
        std::unique_ptr<libcamera::Request> request = camera->createRequest();
        if (request->addBuffer(streamConfig.stream(), buffer.get()) < 0) {
            std::cerr << "Failed to add buffer to request" << std::endl;
            return -1;
        }
        requests.push_back(std::move(request));
    }

    camera->start();

    for (auto &request : requests) {
        if (camera->queueRequest(request.get()) < 0) {
            std::cerr << "Failed to queue request" << std::endl;
            return -1;
        }
    }

    while (!handler.shouldQuit()) {
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }

    camera->stop();
    camera->release();
    manager.stop();

    delete allocator;

    return 0;
}