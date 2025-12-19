using UnityEngine;

public class SewerRoomWaterManager : MonoBehaviour
{
    [Header("Water Settings")]
    [Tooltip("The Transform of the water plane/mesh that will rise.")]
    public Transform waterPlane;
    [Tooltip("The Particle System for floating debris.")]
    public ParticleSystem debrisParticles;
    
    [Header("Rise Settings")]
    [Tooltip("How high (in local Y units) the water should rise.")]
    public float maxWaterHeight = 3.0f; // Adjust based on your room size
    [Tooltip("Units per second the water rises.")]
    public float riseSpeed = 0.5f;
    [Tooltip("Units per second the water drains.")]
    public float drainSpeed = 1.0f;
        [Header("Audio")]
    public AudioSource risingWaterSound;

    private float initialY;
    private bool isFilling = false;
    private bool isDraining = false;

    private void Start()
    {
        if (waterPlane != null)
        {
            initialY = waterPlane.localPosition.y;
        }
        else
        {
            Debug.LogError("SewerRoomWaterManager: Water Plane not assigned!");
        }

        if (debrisParticles == null)
        {
             // Try to find in children (common setup)
             debrisParticles = GetComponentInChildren<ParticleSystem>();
             if (debrisParticles != null) Debug.Log("SewerRoomWaterManager: Auto-found debris particles in children.");
        }

        if (debrisParticles != null)
        {
            debrisParticles.Stop();
        }
        
        if (risingWaterSound != null) risingWaterSound.Stop();
    }

    private void Update()
    {
        if (waterPlane == null) return;

        if (isFilling)
        {
            // Calculate target world position Y (relative to initial)
            float targetY = initialY + maxWaterHeight;
            
            float newY = Mathf.MoveTowards(waterPlane.localPosition.y, targetY, riseSpeed * Time.deltaTime);
            waterPlane.localPosition = new Vector3(waterPlane.localPosition.x, newY, waterPlane.localPosition.z);
            
            // Check if full
            if (Mathf.Abs(waterPlane.localPosition.y - targetY) < 0.01f)
            {
                isFilling = false;
                if (risingWaterSound != null) risingWaterSound.Stop(); // Stop sound when full? Or loop quietly? Usually stop bubbly rise.
                Debug.Log("Sewer Room is full!");
            }
        }
        else if (isDraining)
        {
             float newY = Mathf.MoveTowards(waterPlane.localPosition.y, initialY, drainSpeed * Time.deltaTime);
             waterPlane.localPosition = new Vector3(waterPlane.localPosition.x, newY, waterPlane.localPosition.z);
             
             // Check if empty
             if (Mathf.Abs(waterPlane.localPosition.y - initialY) < 0.01f)
             {
                 isDraining = false;
                 if (debrisParticles != null) debrisParticles.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                 if (risingWaterSound != null) risingWaterSound.Stop();
                 Debug.Log("Sewer Room is drained.");
             }
        }
    }

    public void StartWater()
    {
        isFilling = true;
        isDraining = false;
        
        if (debrisParticles != null)
        {
            if (!debrisParticles.isPlaying) debrisParticles.Play();
        }
        
        if (risingWaterSound != null && !risingWaterSound.isPlaying) risingWaterSound.Play();
    }

    public void StopWater()
    {
        isFilling = false;
        isDraining = true; // Automatically drain when stopped
        
        // Sound can continue while draining if we want, or change. 
        // For simple setup, we'll keep playing it until fully drained.
         if (risingWaterSound != null && !risingWaterSound.isPlaying) risingWaterSound.Play();
    }
}
