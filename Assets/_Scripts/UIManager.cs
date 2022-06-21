using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{

    // UI canvases
    public GameObject escapeMenu;
    public GameObject youWin;

    private void Awake() {
        PlayerController.ToggleEscapeMenu += ToggleEscapeMenu;
        BurnableManager.AllSpritesFreed += DisplayWinText;
    }

    public void ExitGame() {
        Application.Quit();
    }

    public void ToggleEscapeMenu() 
    {
        escapeMenu.SetActive(!escapeMenu.activeInHierarchy);
    }  

    public void DisplayWinText()
    {
        youWin.SetActive(true);
    }

}
