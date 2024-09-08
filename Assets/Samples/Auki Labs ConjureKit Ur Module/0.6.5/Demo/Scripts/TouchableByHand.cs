using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace AukiHandTrackerSample
{
    public class TouchableByHand : MonoBehaviour
    {
        public Main mainScript;
        private GameObject raccoonObject;
        private Animator raccoonAnimator;

        private void Awake()
        {
            Debug.Log("TouchableByHand script started!");
            GameObject.Find("Main");
            mainScript = FindObjectOfType<Main>();
        }

        private void OnTriggerEnter(Collider other)
        {
            Debug.Log("Collider Triggered!");
            
            if (mainScript == null)
            {
                mainScript = FindObjectOfType<Main>();
                if (mainScript == null)
                {
                    Debug.LogError("Main script not found");
                    return;
                }
            }

            if (mainScript.hasPlayedDead)
            {
                Debug.Log("Touch: hasPlayDead" + mainScript.hasPlayedDead);
                mainScript.GetUp();
            } else {
                Debug.Log("Getup: hasPlayDead" + mainScript.hasPlayedDead);
            }
        }
    }
}