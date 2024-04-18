using UnityEngine;
using UnityEngine.SceneManagement;

public class buttons : MonoBehaviour
{
    public string userName;

    public void GoToScene(string sceneName) {
        SceneManager.LoadScene(sceneName);
    }

    public void UserNameInput(string input) {
        print(input);
        userName = input;
    }

    public void QuitApp() {
        Application.Quit();
        Debug.Log("Application has quit.");
    }

}
