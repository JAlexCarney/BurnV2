using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public GameObject sootSpritePrefab;
    public static float size = 10f;
    private readonly float speed = 5f;
    private readonly float rotationSpeed = 0.1f;
    private CharacterController cc;

    // Start is called before the first frame update
    void Start()
    {
        cc = GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void Update()
    {
        var inputVector = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));

        inputVector = GlobalUtil.Rotate(inputVector, -transform.eulerAngles.y);

        if (inputVector.magnitude > 0)
        {
            cc.SimpleMove(new Vector3(inputVector.x, 0f, inputVector.y) * speed);
        }

        if (Input.GetKey(KeyCode.E))
        {
            transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y + rotationSpeed, transform.eulerAngles.z);
        }
        else if (Input.GetKey(KeyCode.Q)) 
        {
            transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y - rotationSpeed, transform.eulerAngles.z);
        }
    }

    private void Consume(BaseBurnable burnable) 
    {
        if (size > burnable.size) {
            size += burnable.size/10f;
            transform.localScale = Vector3.one * size / 10f;
            GameObject sootSprite = Instantiate(sootSpritePrefab, burnable.gameObject.transform.position, new Quaternion());
            sootSprite.GetComponent<SootSprite>().SetFollow(transform);
            Destroy(burnable.gameObject);
        }
    }

    private void OnControllerColliderHit(ControllerColliderHit collider)
    {
        if (collider.gameObject.CompareTag("Burnable")) 
        {
            Consume(collider.gameObject.GetComponent<BaseBurnable>());
        }
    }
}
