using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

namespace Auki.Integration.ARFoundation.Manna
{
    public class FrameFeederGPU : FrameFeederBase
    {
        /// <summary>
        /// AR Camera Manager necessary to supply Manna with camera feed frames.
        /// </summary>
        [SerializeField] protected ARCameraBackground ArCameraBackground;

        private RenderTexture _videoTexture;

        protected override void Awake()
        {
            base.Awake();

            if (ArCameraBackground == null)
                ArCameraBackground = GetComponent<ARCameraBackground>();
        }

        /// <summary>
        /// Manna needs to be supplied with camera feed frames so it can detect QR codes and perform Instant Calibration.
        /// For this particular implementation, we use AR Foundations AR Camera Manager to retrieve the images on CPU side.
        /// </summary>
        protected override void ProcessFrame(ARCameraFrameEventArgs frameInfo)
        {
            CreateOrUpdateVideoTexture();
            if (_videoTexture == null) return;

            CopyVideoTexture();

            MannaInstance.ProcessVideoFrameTexture(
                _videoTexture,
                ArCamera.projectionMatrix,
                ArCamera.worldToCameraMatrix
            );
        }

        private void CreateOrUpdateVideoTexture()
        {
            if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
                if (_videoTexture != null) return;

                var textureNames = ArCameraBackground.material.GetTexturePropertyNames();
                for (var i = 0; i < textureNames.Length; i++)
                {
                    var texture = ArCameraBackground.material.GetTexture(textureNames[i]);
                    if (texture == null || (texture.graphicsFormat != GraphicsFormat.R8_UNorm)) continue;
                    Debug.Log(
                        $"Creating video texture based on: {textureNames[i]}, format: {texture.graphicsFormat}, size: {texture.width}x{texture.height}");
                    _videoTexture = new RenderTexture(texture.width, texture.height, 0, GraphicsFormat.R8_UNorm);
                    break;
                }
            }
            else if (Application.platform == RuntimePlatform.Android)
            {
                var arTexture = !ArCameraBackground.material.HasProperty("_MainTex")
                    ? null
                    : ArCameraBackground.material.GetTexture("_MainTex");
                if (arTexture != null)
                {
                    int width, height;
                    if (Screen.orientation == ScreenOrientation.Portrait ||
                        Screen.orientation == ScreenOrientation.PortraitUpsideDown)
                    {
                        width = arTexture.height;
                        height = arTexture.width;
                    }
                    else
                    {
                        width = arTexture.width;
                        height = arTexture.height;
                    }

                    if (_videoTexture == null || _videoTexture.width != width || _videoTexture.height != height)
                    {
                        if (_videoTexture != null)
                        {
                            Debug.Log($"Current video texture size: {_videoTexture.width}x{_videoTexture.height}");
                            Destroy(_videoTexture);
                        }

                        _videoTexture = null;
                        Debug.Log($"Creating video texture format: {arTexture.graphicsFormat}, size: {width}x{height}");
                        _videoTexture = new RenderTexture(width, height, 0, GraphicsFormat.R8G8B8A8_UNorm);
                        _videoTexture.Create();
                    }
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
                var arTexture = !ArCameraBackground.material.HasProperty("_MainTex")
                    ? null
                    : ArCameraBackground.material.GetTexture("_MainTex");
                Graphics.SetRenderTarget(_videoTexture.colorBuffer, _videoTexture.depthBuffer);
                commandBuffer.ClearRenderTarget(true, false, Color.clear);
                commandBuffer.Blit(arTexture, BuiltinRenderTextureType.CurrentActive, ArCameraBackground.material);
                Graphics.ExecuteCommandBuffer(commandBuffer);
                commandBuffer.Dispose();
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
                var textureY = ArCameraBackground.material.GetTexture("_textureY");
                Graphics.Blit(textureY, _videoTexture);
            }
        }
    }
}
