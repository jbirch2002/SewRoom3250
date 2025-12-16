using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;
using System;

public class FPController : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] private float walkSpeed = 3;
    [SerializeField] private float crouchWalkSpeed = 1;
    [SerializeField] private float sprintMultiplier = 2;
    [SerializeField] private KeyCode sprintKey;
    [SerializeField] private KeyCode crouchKey;
    public KeyCode interactKey;


    [Header("Jumping")]
    [SerializeField] private bool jumpEnabled = true;
    [SerializeField] private float jumpForce = 5;
    [SerializeField] private float gravity = 9.81f;
    [SerializeField] private KeyCode jumpKey = KeyCode.Space;


    [Header("Look Sensitivity")]
    [SerializeField] private float mouseSensitivity = 2;
    [SerializeField] private float upDownRange = 80;

    [Header("Flashlight")]
    [SerializeField] private bool flashLightEnabled;
    [SerializeField] private Light flashlight;
    [SerializeField] private KeyCode flashlightKey;


    [Header("UI")]
    [SerializeField] private Sprite reticle;

    [Header("Footsteps")]
    [SerializeField] private bool footstepsEnabled = true;
    [SerializeField] private AudioClip[] footstepSounds;
    [SerializeField] private float walkStepInterval = 0.5f;
    [SerializeField] private float sprintStepInterval = 0.3f;
    [SerializeField] private float velocityThreshold = 2f;
    private AudioSource footstepSource;

    private float crouchCameraHeight = 0.15f;
    private bool isCrouched = false;
    private bool isCrouching = false;
    private float defaultCameraHeight;
    private float timeNeededToCrouch = 0.25f;
    private float timeElapsedSinceCrouch;
    private Vector3 standingPos;
    private Vector3 crouchedPos;
    private Vector3 startPos;
    private Vector3 endPos;
    private int lastPlayedIndex = -1;
    private float nextStepTime;
    private float verticalRotation;
    private Vector3 currentMovement = Vector3.zero;
    private Camera mainCamera;
    private GameObject currentSurface;
    private GameObject objectInFocus;
    private GameObject lastObjectInFocus;
    public GameObject ObjectInFocus { get { return objectInFocus; } }
    public GameObject CurrentSurface { get { return currentSurface; } }

    public static event Action<GameObject,float> InFocusAtDistance;


    private CharacterController characterController;
    private bool isMoving;




    void Start()
    {
        characterController = GetComponent<CharacterController>();
        footstepSource = GetComponent<AudioSource>();
        mainCamera = Camera.main;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        defaultCameraHeight = mainCamera.transform.localPosition.y;
        standingPos = new Vector3(0, defaultCameraHeight, 0);
        crouchedPos = new Vector3(0, crouchCameraHeight, 0);
    }

    private void Update()
    {
        HandleMovement();
        HandleRotation();
        HandleCrouching();
        CheckObjectInFocus();
        HandleFlashlight();

        if (isMoving) CheckGround();
        if (footstepsEnabled)HandleFootsteps();

        if (objectInFocus != null && lastObjectInFocus != objectInFocus)
        {
            float dist = Vector3.Distance(transform.position, objectInFocus.transform.position);
            InFocusAtDistance?.Invoke(objectInFocus,dist);
            lastObjectInFocus = objectInFocus;
        } 

    }



    void HandleFlashlight()
    {
        if (!flashLightEnabled) return;

        if (Input.GetKeyDown(flashlightKey))
        {
            flashlight.enabled = !flashlight.enabled;
        }

    }


    void HandleMovement()
    {
        float verticalInput = Input.GetAxis("Vertical");
        float horizontalInput = Input.GetAxis("Horizontal");
        float speedMultiplier = Input.GetKey(sprintKey) ? sprintMultiplier : 1;
        float verticalSpeed = isCrouched? verticalInput * crouchWalkSpeed: verticalInput * walkSpeed * speedMultiplier;
        float horizontalSpeed = isCrouched? horizontalInput * crouchWalkSpeed: horizontalInput * walkSpeed * speedMultiplier;

        Vector3 horizontalMovement = new Vector3(horizontalSpeed, 0, verticalSpeed);
        horizontalMovement = transform.rotation * horizontalMovement;


        if (jumpEnabled) HandleJumping();

        currentMovement.x = horizontalMovement.x;
        currentMovement.z = horizontalMovement.z;

        characterController.Move(currentMovement * Time.deltaTime);

        isMoving = verticalInput != 0 || horizontalInput != 0;

    }

    void HandleJumping()
    {
        if (characterController.isGrounded && !isCrouched && !isCrouching)
        {
            if (Input.GetKeyDown(jumpKey))
            {
                currentMovement.y = jumpForce;
            }
        }
        else
        {
            currentMovement.y -= gravity * Time.deltaTime;
        }

    }

    void HandleRotation()
    {
        float mouseXRotation = Input.GetAxis("Mouse X") * mouseSensitivity;
        transform.Rotate(0, mouseXRotation, 0);

        verticalRotation -= Input.GetAxis("Mouse Y") * mouseSensitivity;
        verticalRotation = Mathf.Clamp(verticalRotation, -upDownRange, upDownRange);
        mainCamera.transform.localRotation = Quaternion.Euler(verticalRotation, 0, 0);

    }

    void HandleCrouching()
    {
        if (!characterController.isGrounded) return;

        if (Input.GetKeyDown(crouchKey) && !isCrouching)
        {
            if (!isCrouched)
            {
                startPos = standingPos;
                endPos = crouchedPos;
            }
            else
            {
                startPos = crouchedPos;
                endPos = standingPos;
            }

            isCrouching = true;
        }

        if (isCrouching)
        {
            if (timeElapsedSinceCrouch < timeNeededToCrouch)
            {
                timeElapsedSinceCrouch += Time.deltaTime;
                mainCamera.transform.localPosition = Vector3.Lerp(startPos, endPos, timeElapsedSinceCrouch / timeNeededToCrouch);
            }
            else
            {
                isCrouched = !isCrouched;
                timeElapsedSinceCrouch = 0;
                isCrouching = false;
            }
        }
    }


    void HandleFootsteps()
    {
        float currentStepInterval = (Input.GetKey(sprintKey)) ? sprintStepInterval : walkStepInterval;
        if (characterController.isGrounded && isMoving && Time.time > nextStepTime && characterController.velocity.magnitude > velocityThreshold)
        {
            PlayFootstepSounds();
            nextStepTime = Time.time + currentStepInterval;
        }
    }

    void PlayFootstepSounds()
    {
        int randomIndex;
        float minPitch = 0.8f;
        float maxPitch = 1.2f;

        if (footstepSounds.Length == 1)
        {
            randomIndex = 0;
        }
        else
        {
            randomIndex = UnityEngine.Random.Range(0, footstepSounds.Length - 1);
            if (randomIndex >= lastPlayedIndex)
            {
                randomIndex++;
            }
        }

        lastPlayedIndex = randomIndex;
        footstepSource.clip = footstepSounds[randomIndex];
        footstepSource.pitch = UnityEngine.Random.Range(minPitch, maxPitch);
        footstepSource.Play();
    }

    void CheckGround()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position,Vector3.down,out hit))
        {
            if (hit.transform.gameObject != currentSurface)
            {
                currentSurface = hit.transform.gameObject;
            }
        }
    }

    void CheckObjectInFocus()
    {
        RaycastHit hit;
        if (Physics.Raycast(mainCamera.transform.position, mainCamera.transform.forward, out hit))
        {
            var obj = hit.transform.gameObject;
            if (obj != objectInFocus && obj.GetComponent<MeshRenderer>() != null)
            {
                objectInFocus = obj;
                
            }
        }

    }


}
