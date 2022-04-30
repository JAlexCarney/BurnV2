using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public Transform cameraHolder;
    private new Transform camera;
    private float size = 10f;
    private readonly float horizontalAcc = 1f;
    private readonly float cameraRotationSpeed = 0.05f;
    private readonly float maxSpeed = 2f;
    private Rigidbody rb;
    private bool moving = false;
    private bool cameraMoving = false;

    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        camera = cameraHolder.GetChild(0);
    }

    // Update is called once per frame
    void Update()
    {
        var inputVector = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));

        if (inputVector.magnitude > 0)
        {
            if (!cameraMoving) {
                inputVector = GlobalUtil.Rotate(inputVector, - (cameraHolder.eulerAngles.y));
            }
            rb.AddForce(new Vector3(inputVector.x, 0f, inputVector.y) * horizontalAcc);
            transform.LookAt(new Vector3(transform.position.x + inputVector.x,
                transform.position.y,
                transform.position.z + inputVector.y));
            if (rb.velocity.magnitude > maxSpeed) 
            {
                rb.velocity = rb.velocity.normalized * maxSpeed;
            }
            moving = true;
        }
        else if (moving == true)
        {
            moving = false;
            rb.velocity *= 0;
            transform.LookAt(new Vector3(camera.position.x, transform.position.y, camera.position.z));
        }

        if (Input.GetKey(KeyCode.E))
        {
            cameraHolder.eulerAngles = new Vector3(0f, cameraHolder.eulerAngles.y - cameraRotationSpeed, 0f);
            transform.LookAt(new Vector3(camera.position.x, transform.position.y, camera.position.z));
            cameraMoving = true;
        }
        else if (Input.GetKey(KeyCode.Q))
        {
            cameraHolder.eulerAngles = new Vector3(0f, cameraHolder.eulerAngles.y + cameraRotationSpeed, 0f);
            transform.LookAt(new Vector3(camera.position.x, transform.position.y, camera.position.z));
            cameraMoving = true;
        }
        else 
        {
            cameraMoving = false;
        }
    }

    private void Consume(BaseBurnable burnable) 
    {
        if (size > burnable.size) {
            size += burnable.size/10f;
            transform.localScale = Vector3.one * size / 10f;
            Destroy(burnable.gameObject);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Burnable")) 
        {
            Consume(collision.gameObject.GetComponent<BaseBurnable>());
        }
    }
}
