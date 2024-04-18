using System;
using Auki.ConjureKit;
using Auki.ConjureKit.Manna;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

namespace MannaSampleOnLighthouseTrackedDemo
{
    /// <summary>
    /// This sample shows how to use Manna's onLighthouseTracked callback.
    /// It will be invoked when Manna detects a valid lighthouse and starts tracking it.
    /// A label will show some of the lighthouse's properties.
    /// The sample also has a button that enables you to show or hide a QR code for a lighthouse
    /// that you may scan with another device.
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
        /// Toggle that will be used to show/hide the Manna on-screen (dynamic) QR lighthouse.
        /// </summary>
        public Toggle qrCodeToggle;
        
        /// <summary>
        /// Label that will show data about tracked lighthouses.
        /// </summary>
        public Text statusLabel;
        
        private Manna _manna;
        private RenderTexture _videoTexture;
        private ConjureKit _conjureKit;

        void Start()
        {
            // Initialize the SDK.
            _conjureKit = new ConjureKit(arCamera.transform, "insert_app_key_here", "insert_app_secret_here");

            // Subscribe to ConjureKit state changes so the QR lighthouse toggle can be enabled when connected/calibrated.
            _conjureKit.OnStateChanged += state =>
            {
                if (qrCodeToggle) qrCodeToggle.interactable = state == State.JoinedSession || state == State.Calibrated;
            };
            
            // Initialize Manna and provide a custom onLighthouseTracked selector.
            _manna = new Manna(_conjureKit);
            _manna.OnLighthouseTracked += UpdateStatusLabel;
            
            // Everything is set up so let's connect.
            _conjureKit.Connect();
        }

        private void Update()
        {
            if (_conjureKit?.GetSession() == null) return;
            FeedMannaWithVideoFrames();
        }

        /// <summary>
        /// Method that shows/hides the Manna on-screen (dynamic) QR lighthouse.
        /// </summary>
        /// <param name="status">true to show lighthouse, false to hide it</param>
        public void ToggleLighthouse(bool status) => _manna.SetLighthouseVisible(status);

        /// <summary>
        /// This basic implementation will update the status label on the screen with the tracked lighthouse's type, id and world pose.
        /// </summary>
        /// <param name="lighthouse">Tracked lighthouse object</param>
        /// <param name="pose">Tracked lighthouse pose</param>
        /// <param name="isCloseEnough">true if the lighthouse is close enough for calibration, false if it's not</param>
        private void UpdateStatusLabel(Lighthouse lighthouse, Pose pose, bool isCloseEnough)
        {
            statusLabel.text = $"Lighthouse data:\n" +
                               $"Type: {lighthouse.Type}\n" +
                               $"Id: {lighthouse.Id}\n" +
                               $"Position: {pose.position:0.00}\n" +
                               $"Rotation: {pose.rotation.eulerAngles:0.00}";
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