using System;
using Auki.Integration.ARFoundation.Manna;
using UnityEngine.XR.ARFoundation;

namespace Auki.ConjureKit.Manna
{
    public static class MannaExtensions
    {
        /// <summary>
        /// This is a helper extension method, which does the following things for you:
        /// - finds the ARCameraManager in the scene and checks that at least one and only one is active
        /// - gets or creates the suggested FrameFeeder component on the ARCameraManager object
        /// - attaches the Manna instance to it
        /// You can use your own implementation or one of the provided ones, inheriting from FrameFeederBase.
        /// </summary>
        /// <param name="manna">Your instance of Manna</param>
        /// <returns>The FrameFeeder component added (or already present) on the ARCameraManager GameObject</returns>
        /// <exception cref="InvalidOperationException">Throws in case there is 0 or more than 1 ARCameraManager in the scene.</exception>
        public static FrameFeederGPU GetOrCreateFrameFeederComponent(this Manna manna)
        {
            return GetOrCreateFrameFeederComponent<FrameFeederGPU>(manna);
        }

        /// <summary>
        /// This is a helper extension method, which does the following things for you:
        /// - finds the ARCameraManager in the scene and checks that at least one and only one is active
        /// - gets or creates the suggested FrameFeeder component on the ARCameraManager object
        /// - attaches the Manna instance to it
        /// You can use your own implementation or one of the provided ones, inheriting from FrameFeederBase.
        /// </summary>
        /// <param name="manna">Your instance of Manna</param>
        /// <typeparam name="T">The implementation of FrameFeeder to use, responsible to feed frames to Manna from ARFoundation</typeparam>
        /// <returns>The FrameFeeder component added (or already present) on the ARCameraManager GameObject</returns>
        /// <exception cref="InvalidOperationException">Throws in case there is 0 or more than 1 ARCameraManager in the scene.</exception>
        public static T GetOrCreateFrameFeederComponent<T>(this Manna manna) where T : FrameFeederBase
        {
            // Find ARCameraManager in scene and check we have only one
            var cameraManagersInScene = UnityEngine.Object.FindObjectsOfType<ARCameraManager>(false);
            if (cameraManagersInScene == null || cameraManagersInScene.Length == 0)
                throw new InvalidOperationException("Could not setup Manna with ARFoundation. An active ARCameraManager is required in the scene.");
            if (cameraManagersInScene.Length != 1)
                throw new InvalidOperationException("Could not setup Manna with ARFoundation. Only one ARCameraManager needs to be active in the scene.");

            // Check if a FrameFeeder component is already attached
            T component = cameraManagersInScene[0].gameObject.GetComponent<T>();
            // If not, add it
            if (component == null)
                component = cameraManagersInScene[0].gameObject.AddComponent<T>();
            
            // Return component
            return component;
        }
    }

}
