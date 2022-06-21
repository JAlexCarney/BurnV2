using System;
using System.Collections.Generic;
using UnityEngine;

public class BurnableManager : MonoBehaviour
{
    // invoked when player has consumed all burnable objs 
    public static Action AllSpritesFreed;

    [SerializeField]
    List<BaseBurnable> allBurnables = new List<BaseBurnable>();

    // Start is called before the first frame update
    void OnEnable()
    {
        PlayerController.ConsumedBurnable += Consume;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void Consume(BaseBurnable consumed)
    {
        allBurnables.Remove(consumed);
        if (allBurnables.Count == 0)
        {
            AllSpritesFreed.Invoke();
        }
       Destroy(consumed.gameObject);
    }

    [ContextMenu("Autofill allBurnables")]
    void AutofillAllBurnables()
    {
        allBurnables.Clear();
        foreach (BaseBurnable b in GetComponentsInChildren<BaseBurnable>()) 
        {
            allBurnables.Add(b);
        }
    }
        
}
