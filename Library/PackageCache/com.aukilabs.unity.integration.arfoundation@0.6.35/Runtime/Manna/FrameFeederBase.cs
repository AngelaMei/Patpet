using UnityEngine;
using UnityEngine.XR.ARFoundation;

namespace Auki.Integration.ARFoundation.Manna
{
    public abstract class FrameFeederBase : MonoBehaviour
    {
        /// <summary>
        /// AR Camera Manager necessary to supply Manna with camera feed frames.
        /// </summary>
        [SerializeField] protected ARCameraManager ArCameraManager;

        /// <summary>
        /// AR Camera necessary to supply Manna with camera transformation matrices and for ConjureKit's constructor.
        /// </summary>
        [SerializeField] protected Camera ArCamera;

        /// <summary>
        /// The minimum amount of time that should pass between feeding each frame to Manna (in seconds).
        /// This effectively throttles the frame feeding from ARFoundation to Manna, dropping the frames in between.
        /// Default value is 0 = feed a new frame to Manna as soon as it is available.
        /// </summary>
        [SerializeField] public float FeedInterval = 0;
        
        protected ConjureKit.Manna.Manna MannaInstance;
        protected bool IsMannaInit = false;
        
        private float _previousFeedTime = 0;

        protected virtual void Awake()
        {
            if (ArCameraManager == null)
                ArCameraManager = GetComponent<ARCameraManager>();
            if (ArCamera == null)
                ArCamera = GetComponent<Camera>();
        }

        protected virtual void OnEnable()
        {
            ArCameraManager.frameReceived += OnCameraFrameReceived;
        }

        protected virtual void OnDisable()
        {
            ArCameraManager.frameReceived -= OnCameraFrameReceived;
        }

        public void AttachMannaInstance(ConjureKit.Manna.Manna mannaInstance)
        {
            MannaInstance = mannaInstance;
            
            // Wait for Manna initialization to actually start feeding frames to it
            MannaInstance.OnInit += config =>
            {
                IsMannaInit = true;
            };
        }

        private bool HasFeedTimerElapsed()
        {
            float now = Time.realtimeSinceStartup;
            float elapsedTimeFromLastFeed = now - _previousFeedTime;
            return elapsedTimeFromLastFeed > FeedInterval;
        }

        private void ResetFeedTimer()
        {
            _previousFeedTime = Time.realtimeSinceStartup;
        }
        
        private void OnCameraFrameReceived(ARCameraFrameEventArgs args)
        {
            if (IsMannaInit && HasFeedTimerElapsed())
            {
                ResetFeedTimer();
                ProcessFrame(args);
            }
        }
        
        protected abstract void ProcessFrame(ARCameraFrameEventArgs frameInfo);
    }
}
