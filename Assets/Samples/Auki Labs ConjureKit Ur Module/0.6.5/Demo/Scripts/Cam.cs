using UnityEngine;
using UnityEngine.UI;

public class Cam : MonoBehaviour
{
    [SerializeField] private RawImage img = default;
    private WebCamTexture webCam;


    void Start()
    {
        webCam = new WebCamTexture();
        if(!webCam.isPlaying) webCam.Play();
        img.texture = webCam;
    }
}