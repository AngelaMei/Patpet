using System;
using System.Linq;
using Auki.ConjureKit;
using Auki.ConjureKit.Manna;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

namespace MannaSampleCustomStaticLighthouseSelectorDemo
{
    /// <summary>
    /// This sample shows how to implement a custom static lighthouse selector for Manna.
    /// Before use a static lighthouse needs to be created in the Auki Console and placed with Auki Lightkeeper.
    /// Static lighthouses can be included in many domains so we've provided the ability for the app
    /// to choose which particular domain lighthouse pose will be used for calibration.
    /// When a static lighthouse is scanned the SelectLatestStaticLighthousePose method will be invoked
    /// and it will choose the latest placement and will calibrate from it. The statusLabel will be updated when the calibration process completes.
    /// </summary>
    public class Main : MonoBehaviour
    {
        /// <summary>
        /// AR Camera Background necessary to supply Manna with camera feed frames.
        /// </summary>
        public ARCameraBackground arCameraBackground;

        /// <summary>
        /// AR Camera necessary to supply Manna with camera transformation matrices and for ConjureKit's constructor.
        /// </summary>
        public Camera arCamera;
        
        /// <summary>
        /// Label that will indicate when a calibration from a static lighthouse has been achieved.
        /// </summary>
        public Text statusLabel;
        
        private ConjureKit _conjureKit;
        private Manna _manna;
        private RenderTexture _videoTexture;
        private bool _waitingForStaticLighthouseCalibration;
        
        void Start()
        {
            // Initialize the SDK.
            _conjureKit = new ConjureKit(arCamera.transform, "insert_app_key_here", "insert_app_secret_here");

            // Initialize Manna and provide a custom static lighthouse pose selector.
            _manna = new Manna(_conjureKit);
            _manna.SetStaticLighthousePoseSelector(SelectLatestStaticLighthousePose);
            
            // Subscribe to Manna calibration success handler and wait for static lighthouse calibration.
            _manna.OnCalibrationSuccess += _ =>
            {
                if (!_waitingForStaticLighthouseCalibration || _conjureKit.GetState() != State.Calibrated) return;
                _waitingForStaticLighthouseCalibration = false;
                statusLabel.text = "Calibrated from a static lighthouse";
            };

            // Subscribe to calibration failure handler in case something goes wrong.
            _manna.OnCalibrationFailed += data =>
            {
                statusLabel.text = "Calibration failed, check console log";
                Debug.Log($"Static lighthouse calibration failed: {data.Reason}");
            };

            // Everything is set up so let's connect.
            _conjureKit.Connect();
        }
        
        private void Update()
        {
            if (_conjureKit?.GetSession() == null) return;
            FeedMannaWithVideoFrames();
        }
        
        /// <summary>
        /// This basic implementation of the static lighthouse pose selector will choose the pose from the latest placement.
        /// </summary>
        /// <param name="lighthousePoses">Array of LighthousePoses</param>
        /// <param name="onPoseSelected">Call with chosen LighthousePose</param>
        private void SelectLatestStaticLighthousePose(StaticLighthouseData staticLighthouseData, Action<LighthousePose> onPoseSelected)
        {
            _waitingForStaticLighthouseCalibration = true;
            onPoseSelected(staticLighthouseData.poses.OrderBy(p => p.placedAt).Last());
        }
        
        /// <summary>
        /// Manna needs to be supplied with camera feed frames so it can detect QR codes and perform Instant Calibration.
        /// For this particular Sample we'll be using AR Foundations AR Camera Background to retrieve the images.
        /// </summary>
        private void FeedMannaWithVideoFrames()
        {
            if (_videoTexture == null) CreateVideoTexture();
            if (_videoTexture == null) return;

            CopyVideoTexture();

            _manna.ProcessVideoFrameTexture(
                _videoTexture,
                arCamera.projectionMatrix,
                arCamera.worldToCameraMatrix
            );
        }
        
        private void CreateVideoTexture()
        {
            if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
                var textureNames = arCameraBackground.material.GetTexturePropertyNames();
                for (var i = 0; i < textureNames.Length; i++)
                {
                    var texture = arCameraBackground.material.GetTexture(textureNames[i]);
                    if (texture == null || (texture.graphicsFormat != GraphicsFormat.R8_UNorm)) continue;
                    Debug.Log($"Creating video texture based on: {textureNames[i]}, format: {texture.graphicsFormat}, size: {texture.width}x{texture.height}");
                    _videoTexture = new RenderTexture(texture.width, texture.height, 0, GraphicsFormat.R8G8B8A8_UNorm);
                    break;
                }
            }
            else if (Application.platform == RuntimePlatform.Android)
            {
                var arTexture = !arCameraBackground.material.HasProperty("_MainTex") ? null : arCameraBackground.material.GetTexture("_MainTex");
                if (arTexture != null)
                {
                    Debug.Log($"Creating video texture format: {arTexture.graphicsFormat}, size: {arTexture.width}x{arTexture.height}");
                    _videoTexture = new RenderTexture(arTexture.height, arTexture.width, 0, GraphicsFormat.R8G8B8A8_UNorm);
                }
            }
        }
        
        private void CopyVideoTexture()
        {
            // Copy the camera background to a RenderTexture
            if (Application.platform == RuntimePlatform.Android)
            {
                var commandBuffer = new CommandBuffer();
                commandBuffer.name = "AR Camera Background Blit Pass";
                var arTexture = !arCameraBackground.material.HasProperty("_MainTex") ? null : arCameraBackground.material.GetTexture("_MainTex");
                Graphics.SetRenderTarget(_videoTexture.colorBuffer, _videoTexture.depthBuffer);
                commandBuffer.ClearRenderTarget(true, false, Color.clear);
                commandBuffer.Blit(arTexture, BuiltinRenderTextureType.CurrentActive, arCameraBackground.material);
                Graphics.ExecuteCommandBuffer(commandBuffer);
                commandBuffer.Dispose();
            }
            else if(Application.platform == RuntimePlatform.IPhonePlayer)
            {
                var textureY = arCameraBackground.material.GetTexture("_textureY");
                Graphics.Blit(textureY, _videoTexture);
            }
        }
    }
}