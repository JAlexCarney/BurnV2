using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SootSprite : MonoBehaviour
{
    private Transform follow;
    private Rigidbody rb;
    private GameObject visual;
    private float speed = 0.25f;
    private float minDistance = 1.5f;
    private float maxDistance = 3f;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        visual = transform.GetChild(0).gameObject;
    }

    void Update()
    {
        Vector3 adjustedFollowPosition = follow.transform.position - (follow.transform.forward * (PlayerController.size/10f));
        float distance = (adjustedFollowPosition - transform.position).magnitude;
        if (distance > maxDistance)
        {
            rb.AddForce((follow.transform.position - transform.position).normalized * speed);
        }
        else if (distance < minDistance)
        {
            rb.AddForce(-(follow.transform.position - transform.position).normalized * speed);
        } 

        visual.transform.LookAt(Camera.main.transform.position);
    }

    public void SetFollow(Transform f) 
    {
        follow = f;
    }
}
