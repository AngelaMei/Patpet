using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReadInput : MonoBehaviour
{
    public string dollname;

    public void ReadStringInput(string s)
    {
        dollname = s;
        // Debug.Log(input);
        PlayerPrefs.SetString("DollName", dollname);
    }
    
}
