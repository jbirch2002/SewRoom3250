using UnityEngine;

public class DoorTriggers : MonoBehaviour
{
    private bool playerInRange = false;
    private FPController player;
    public Door door;
    private Light spotLight;

    private Material slMat;
    public MeshRenderer slRend;


    private void Start()
    {
        player = GameObject.Find("Player").GetComponent<FPController>();

        slMat = slRend.material;
        spotLight = slRend.gameObject.GetComponentInChildren<Light>();
        spotLight.enabled = false;

    }
    private void Update()
    {
        if (playerInRange && DoorIsInteractable())
        {
            if (Input.GetKeyDown(player.interactKey) || Input.GetMouseButtonDown(0))
            {
                door.Interact();
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        playerInRange = other.CompareTag("Player");
        if (playerInRange) ActivateLight(true);


    }
    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            playerInRange = false;
            ActivateLight(false);
        }

    }

    bool DoorIsInteractable()
    {
        var d = player.ObjectInFocus.GetComponent<Door>();
        var playerLookingAtDoor = d != null;
        return playerLookingAtDoor && d == door; 
    }

    void ActivateLight(bool on)
    {
        if (on)
        {
            if (!slMat.IsKeywordEnabled("_EMISSION")) slMat.EnableKeyword("_EMISSION");
            spotLight.enabled = true;

        }
        else 
        {
            if (slMat.IsKeywordEnabled("_EMISSION")) slMat.DisableKeyword("_EMISSION");
            spotLight.enabled = false;
        }

    }
}
