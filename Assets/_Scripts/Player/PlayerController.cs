using System;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    // events 
    public static event Action ToggleEscapeMenu;
    public static event Action<BaseBurnable> ConsumedBurnable; 

    // components 
    private CharacterController cc;
    private PlayerVisual playerVisual;

    // movement stuff
    private readonly float speed = 5f;
    private readonly float rotationSpeed = 0.5f;

    // player size
    public static float size = 10f;


    // Start is called before the first frame update
    void Start()
    {
        cc = GetComponent<CharacterController>();
        playerVisual = GetComponent<PlayerVisual>();
    }

    // Update is called once per frame
    void Update()
    {
        var inputVector = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));

        inputVector = GlobalUtil.Rotate(inputVector, -transform.eulerAngles.y);

        if (inputVector.magnitude > 0)
        {
            Vector3 direction = new Vector3(inputVector.x, 0f, inputVector.y);
            cc.SimpleMove(direction * speed);

            playerVisual.Move(this.transform.position); // call static method for visual stuff
        }

        if (Input.GetKey(KeyCode.E))
        {
            transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y + rotationSpeed, transform.eulerAngles.z);
        }
        else if (Input.GetKey(KeyCode.Q)) 
        {
            transform.eulerAngles = new Vector3(transform.eulerAngles.x, transform.eulerAngles.y - rotationSpeed, transform.eulerAngles.z);
        }

        else if (Input.GetButtonDown("Escape")) // pull up escape menu
        {
            ToggleEscapeMenu?.Invoke();
        }

    }

    private void OnControllerColliderHit(ControllerColliderHit collider)
    {
        if (collider.gameObject.CompareTag("Burnable")) 
        {
            BaseBurnable burnable = collider.gameObject.GetComponent<BaseBurnable>();
            if (size > burnable.size) {
                size += burnable.size/10f;
                ConsumedBurnable?.Invoke(burnable);
            }
        }
    }
}
