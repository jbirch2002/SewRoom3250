using UnityEngine;
using System;

public class Door : MonoBehaviour
{ 
    public Transform[] doorKnobs;

    private float yAngleOpen = 115;
    private float xAngleKnob = -45;
    private Vector3 doorOpenRot;
    private Vector3 knobOpenRot;
    private Vector3 defaultDoorRot;

    private float timeSinceKnobActived;
    private float knobRestoreTime = 1;
    private float timeSinceDoorInteracted;
    private float doorOpeningTime = 1f;
    private bool knobPressed = false;
    private bool doorActive = false;
    public bool doorOpen = false;
    public bool inverted;

    public AudioClip doorOpenSound;
    public AudioClip doorCloseSound;

    private AudioSource doorSource;

    public static event Action<float, Door> DoorOpening;
    public static event Action<float, Door> DoorClosing;




    void Start()
    {
        doorOpenRot = inverted ? new Vector3(0, -180 + yAngleOpen, 0) : new Vector3(0, yAngleOpen, 0);
        defaultDoorRot = inverted ? new Vector3(0, -180, 0) : Vector3.zero;
        //doorOpenRot = new Vector3(0, yAngleOpen, 0);
        knobOpenRot = new Vector3(xAngleKnob, 0, 0);

        doorSource = GetComponent<AudioSource>();
        
    }

    void Update()
    {
        HandleDoorKnobs();
        HandleDoor();
        
    }

    public void Interact()
    {
        foreach(var knob in doorKnobs)
        {
            knob.localRotation = Quaternion.Euler(knobOpenRot);
        }
        knobPressed = true;

        doorActive = true;

        if (!doorOpen)
        {
            PlayDoorOpenSound();
            DoorOpening?.Invoke(doorOpeningTime, this);
        }
        else
        {
            DoorClosing?.Invoke(doorOpeningTime, this);
        }

    }

    void HandleDoor()
    {
        if (doorActive)
        {
            if (!doorOpen)
            {
                RotateDoor(defaultDoorRot, doorOpenRot, false);
            }
            else
            {
                RotateDoor(doorOpenRot, defaultDoorRot, true);
            }
        }
    }

    void RotateDoor(Vector3 rot, Vector3 targetRot, bool closed)
    {
        if (timeSinceDoorInteracted < doorOpeningTime)
        {
            timeSinceDoorInteracted += Time.deltaTime;
            Vector3 newRot = Vector3.Lerp(rot, targetRot, timeSinceDoorInteracted / doorOpeningTime);
            transform.localRotation = Quaternion.Euler(newRot);
        }
        else
        {
            transform.localRotation = Quaternion.Euler(targetRot);
            timeSinceDoorInteracted = 0;
            doorOpen = !doorOpen;
            doorActive = false;
            if (closed) PlayDoorCloseSound();

        }

        

    }

    void HandleDoorKnobs()
    {
        if (knobPressed)
        {
            if (timeSinceKnobActived < knobRestoreTime)
            {
                timeSinceKnobActived += Time.deltaTime;
                Vector3 newRot = Vector3.Lerp(knobOpenRot, Vector3.zero, timeSinceKnobActived / knobRestoreTime);
                foreach (var knob in doorKnobs)
                {
                    knob.localRotation = Quaternion.Euler(newRot);
                }

            }
            else
            {
                foreach (var knob in doorKnobs)
                {
                    knob.localRotation = Quaternion.Euler(Vector3.zero);
                }
                timeSinceKnobActived = 0;
                knobPressed = false;
            }
        }
  
    }

    void PlayDoorOpenSound()
    {
        doorSource.clip = doorOpenSound;
        doorSource.Play();
    }

    void PlayDoorCloseSound()
    {
        doorSource.clip = doorCloseSound;
        doorSource.Play();
    }


}
