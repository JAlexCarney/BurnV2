using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerVisual : MonoBehaviour
{
    // scene references
    [Header("Scene references")]
    public GameObject mesh; 
    public ParticleSystem topParticles; 
    public ParticleSystem sideParticles; 
    public MeshRenderer face; 
    public Material fireLightMat;

    private int shPropPos = Shader.PropertyToID("_PlayerPos"); 

    void OnEnable()
    {
        fireLightMat.SetVector(shPropPos, this.transform.position);
    }

    public void Move(Vector3 pos) {
        fireLightMat.SetVector(shPropPos, pos); 
        
        topParticles.GetComponent<Renderer>().sharedMaterial.SetFloat("_PlayerBase", this.transform.position.y);
        this.GetComponent<Animator>().SetBool("walking", true);
        face.gameObject.GetComponent<Animator>().SetBool("walking", true);
    }
    
    public void Idle()
    {
        this.GetComponent<Animator>().SetBool("walking", false);
        face.gameObject.GetComponent<Animator>().SetBool("walking", false);
    }
 
 }

