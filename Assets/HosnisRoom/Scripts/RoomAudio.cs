using UnityEngine;
using UnityEngine.Audio;

public class RoomAudio : MonoBehaviour
{
    public Room room;
    private FPController player;
    private bool playerInRoom;
    private bool doorOpen;

    public AudioMixer mixer;
    public AudioMixerSnapshot roomSS;
    public AudioMixerSnapshot corridor_doorOpenSS;
    public AudioMixerSnapshot corridor_doorClosedSS;

    public float ssTransitionTime = 0;

    private void OnEnable()
    {
        Door.DoorOpening += DoorSnapshotTransitions;
        Door.DoorClosing += DoorSnapshotTransitions;
        
    }

    private void OnDisable()
    {
        Door.DoorOpening -= DoorSnapshotTransitions;
        Door.DoorClosing -= DoorSnapshotTransitions;

    }



    private void Start()
    {
        player = GameObject.Find("Player").GetComponent<FPController>();
        
    }



    private void Update()
    {
        playerInRoom = room.playerInRoom;
        doorOpen = room.door.doorOpen;

        if (player.CurrentSurface == null) return;

        if (playerInRoom)
        {
            roomSS.TransitionTo(ssTransitionTime);
        }


        if (player.CurrentSurface.CompareTag("Rug") || !playerInRoom)
        {
            mixer.SetFloat("footstepCutoff", 360);
        }
        else
        {
            mixer.SetFloat("footstepCutoff", 5000);
        }

    }


    private void DoorSnapshotTransitions(float time, Door door)
    {
        if (door != room.door) return;

        if (doorOpen)
        {
            corridor_doorClosedSS.TransitionTo(time);

        }
        else
        {
            corridor_doorOpenSS.TransitionTo(time);

        }

    }


   

}
