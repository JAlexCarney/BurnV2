using System;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    // events 
    public static event Action ToggleEscapeMenu;
    public static event Action<BaseBurnable> ConsumedBurnable; 
    public PlayerVisual playerVisual;

    // components 
    private CharacterController cc;
    public Transform cam; 

    // movement stuff
    private readonly float speed = 5f;
    private readonly float rotationSpeed = 0.5f;

    public float turnSmoothTime = 0.1f; 

    private float turnSmoothVelocity; 

    // player size
    public static float size = 10f;


    // Start is called before the first frame update
    void Start()
    {
        cc = GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void Update()
    {
        var inputVector = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));

        // inputVector = GlobalUtil.Rotate(inputVector, -transform.eulerAngles.y);

        if (inputVector.magnitude > 0)
        {
            // Vector3 direction = new Vector3(inputVector.y, 0f, -inputVector.x).normalized; //input adjusted based on camera pos and global vectors 

            Vector3 direction = new Vector3(inputVector.y, 0f, -inputVector.x).normalized;
            float targetAngle = Mathf.Atan2(direction.x, direction.z) * Mathf.Rad2Deg + cam.eulerAngles.y;
            float angle = Mathf.SmoothDampAngle(transform.eulerAngles.y, targetAngle, ref turnSmoothVelocity, turnSmoothTime); 
            transform.rotation = Quaternion.Euler(0f, angle, 0f);

            playerVisual.Move(this.transform.position); // call static method for visual stuff

            Vector3 moveDir = Quaternion.Euler(0f, targetAngle, 0f) * Vector3.forward;

            cc.SimpleMove(moveDir * speed);
        }
        else if (Input.GetButtonDown("Escape")) // pull up escape menu
        {
            ToggleEscapeMenu?.Invoke();
        }
        else 
        {
            playerVisual.Idle();
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
