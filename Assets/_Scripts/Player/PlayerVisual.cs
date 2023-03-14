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
    public GameObject sootSpritePrefab;
    public MeshRenderer face; 

    [Tooltip("Literally any object that has the firelight shader lmao")]
    public GameObject fireLight;   

    // if player is currently squishing
    private bool squishing; 

    // firelight vars
    private int shPropPos = Shader.PropertyToID("_LightPos"); // this is a shader property - store it in a var just to speed things up a lil
    private Material fireLightSharedMat;


    void OnEnable()
    {
        PlayerController.ConsumedBurnable += Consume;
        fireLightSharedMat = fireLight.GetComponent<Renderer>().sharedMaterials[1];

    }

    public void Move(Vector3 pos) { // making this a static bc i dont feel like having MORE references :) idk if i should change this lmao 

        fireLightSharedMat.SetVector(shPropPos, pos); 
        
        // topParticles.GetComponent<Renderer>().sharedMaterial.SetFloat("_PlayerHeight", mesh.GetComponent<Renderer>().bounds.size.y);
        topParticles.GetComponent<Renderer>().sharedMaterial.SetFloat("_PlayerBase", this.transform.position.y);
        this.GetComponent<Animator>().Play("Walking", 0);
    }

    IEnumerator Squish(Vector3 direction)
    {
        if (squishing == true) yield break; 

        squishing = true; 

        Vector3 originalScale = mesh.transform.localScale;

        float time = 0; 
        for (float stretch = 0; stretch >= 0; stretch = Mathf.Sin(time)*.3f) 
        {
            // c.a = stretc
            Vector3 stretchedScale = new Vector3(originalScale.x * (1 + stretch), originalScale.y, originalScale.z);
            mesh.transform.localScale = stretchedScale;
            time += Time.deltaTime;
            yield return null; 
        }
        squishing = false; 
        mesh.transform.localScale = originalScale;
    }

// WARNING: the burnable gets destroeyd in burnable manager, will this clash with  this method??!??!? I have no idea
    // TODO: I have no idea if soot sprite instantiation should be put in a different class 
    private async void Consume(BaseBurnable burnable) 
    {
        transform.localScale = Vector3.one * PlayerController.size / 10f;
        
        // increase particles 

        //TODO: probably seperate this and for the love of god figure out how to tweak particles so they dont look jank when the player is big
        var topShape = topParticles.shape;
        topShape.radius =  .73f * PlayerController.size/10f;
        var topEmission = topParticles.emission; 
        topEmission.rateOverTime = 28 + PlayerController.size/2f;

        var sideShape = sideParticles.shape;
        sideShape.radius =  .93f * PlayerController.size/10f;
        var sideEmission = sideParticles.emission; 
        sideEmission.rateOverTime = 28 + PlayerController.size/2f;

        GameObject sootSprite = Instantiate(sootSpritePrefab, burnable.gameObject.transform.position, new Quaternion());

        // TODO: DONT HARDCODE THIS IN OMG
        if (burnable.size > 5) // instantiate a fuck ton for the last burnable object
        {
            PlayerController.size += 3;
            transform.localScale = Vector3.one * PlayerController.size / 10f;
            for (int i = 0; i < 20; i++)
            {
                GameObject MANYSPRITES = Instantiate(sootSpritePrefab, burnable.gameObject.transform.position, new Quaternion());
                MANYSPRITES.GetComponent<SootSprite>().SetFollow(transform);
            }

            topShape.radius =  topShape.radius * PlayerController.size/12f;
            topEmission.rateOverTime = 28 + PlayerController.size/2f;

            sideShape.radius =  sideShape.radius * PlayerController.size/12f;
            sideEmission.rateOverTime = 28 + PlayerController.size/2f;
        }
        sootSprite.GetComponent<SootSprite>().SetFollow(transform);
    }

    public void SetExpression(Texture tex)
    {
        face.materials[0].SetTexture("_MainTex", tex);
    }
 }

