using Auki.ConjureKit;
using Auki.ConjureKit.Manna;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.UI;
using UnityEngine.XR.ARFoundation;

namespace MannaSample
{
    /// <summary>
    /// This sample shows how to use Manna for the most common cases:
    /// - Showing a dynamic lighthouse.
    /// - Scanning a dynamic lighthouse and performing an instant calibration into the same session.
    /// * After connecting the QR button on the right part of the screen will show or hide a QR code for a lighthouse that you may scan with another device.
    /// This will trigger the Instant Calibration process that will bring the scanning device in a shared AR session with the host.
    /// * The Leave button will disconnect you from the current Session and connect you to a new one.
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
        /// When pressed will leave the current ConjureKit session.
        /// </summary>
        public Button leaveButton;

        /// <summary>
        /// When connected this toggle will allow you to show/hide the dynamic QR lighthouse
        /// which can be scanned by other devices to join & calibrate into the session of this device.
        /// </summary>
        public Toggle qrCodeToggle;

        /// <summary>
        /// Label that shows currently joined session id.
        /// </summary>
        public Text sessionInfo;

        /// <summary>
        /// Label that shows current ConjureKit state.
        /// </summary>
        public Text conjureKitStateInfo;

        private ConjureKit _conjureKit;
        private Manna _manna;
        private string _lastJoinedSessionId;
        private RenderTexture _videoTexture;

        private void Start()
        {
            // Initialize the SDK.
            _conjureKit = new ConjureKit(arCamera.transform, "insert_app_key_here", "insert_app_secret_here");
            
            _conjureKit.OnJoined += session => sessionInfo.text = session.Id;

            _conjureKit.OnLeft += _ =>
            {
                if (sessionInfo != null) sessionInfo.text = "";
            };

            _conjureKit.OnStateChanged += state =>
            {
                if (conjureKitStateInfo) conjureKitStateInfo.text = state.ToString();
                ToggleControlsState(state == State.JoinedSession || state == State.Calibrated);
            };

            _manna = new Manna(_conjureKit);

            // Everything is set up so let's connect.
            _conjureKit.Connect();
        }

        private void ToggleControlsState(bool interactable)
        {
            if (leaveButton) leaveButton.interactable = interactable;
            if (qrCodeToggle) qrCodeToggle.interactable = interactable;
        }

        private void Update()
        {
            if (_conjureKit?.GetSession() == null) return;
            FeedMannaWithVideoFrames();
        }

        /// <summary>
        /// Toggles showing/hiding of Manna QR lighthouse.
        /// </summary>
        public void ToggleLighthouse() => _manna.SetLighthouseVisible(qrCodeToggle.isOn);

        /// <summary>
        /// Leaves the current session.
        /// </summary>
        public void LeaveSession()
        {
            Debug.Log("Leaving session.");
            _conjureKit.Disconnect();
            _conjureKit.Connect();
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