using UnityEngine;

public class ValveController : MonoBehaviour
{
    [Header("Valve Settings")]
    [SerializeField] private bool isOpen = false;
    [SerializeField] private float rotationSpeed = 5f; // Lerp speed multiplier (higher = faster)
    [SerializeField] private float openRotation = 90f; // Total rotation to open
    
    [Header("Water Flow")]
    [SerializeField] private ParticleSystem waterFlow;
    [SerializeField] private AudioSource waterSound; // Optional water sound
    
    private bool waterIsFlowing = false;
    
    [Header("Interaction")]
    [SerializeField] private float interactionDistance = 3f;
    [SerializeField] private KeyCode interactKey = KeyCode.E;
    
    private Transform valveHandle; // The rotating part of the valve
    private float currentRotation = 0f;
    private bool isRotating = false;
    private Camera playerCamera;
    private FPController playerController;
    private Quaternion initialRotation; // Store the initial rotation of the valve
    
    [Header("Animation")]
    [SerializeField] private Animator valveAnimator; // For Animator Controller animations
    [SerializeField] private Animation valveAnimation; // For legacy Animation component
    [SerializeField] private string spinAnimationName = "Spin"; // Name of the spin animation
    
    void Start()
    {
        // Find the valve handle (child object that rotates)
        // If your valve has a rotating part, assign it in inspector or find it here
        if (transform.childCount > 0)
        {
            valveHandle = transform.GetChild(0); // Adjust index as needed
        }
        else
        {
            valveHandle = transform; // Rotate the whole object if no child
        }
        
        // Store the initial rotation so we can rotate relative to it
        initialRotation = valveHandle.localRotation;
        currentRotation = 0f; // Start at 0 rotation offset
        
        // Try to find Animator or Animation component if not assigned
        if (valveAnimator == null)
        {
            valveAnimator = GetComponent<Animator>();
            if (valveAnimator == null)
            {
                valveAnimator = GetComponentInChildren<Animator>();
            }
        }
        
        // We no longer strictly disable the Animator, as it might be the only working way to play the clip
        if (valveAnimator != null)
        {
            // We'll keep it enabled but ensure it doesn't auto-play if we can help it
            // usually handled by state machine default state
            Debug.Log("Animator component found.");
        }
        
        if (valveAnimation == null)
        {
            valveAnimation = GetComponent<Animation>();
            if (valveAnimation == null)
            {
                valveAnimation = GetComponentInChildren<Animation>();
            }
        }
        
        // Disable "Play Automatically" on Animation component to prevent constant playing
        if (valveAnimation != null)
        {
            valveAnimation.playAutomatically = false;
            valveAnimation.Stop(); // Stop any playing animation
            
            // The clip is already in the scene's m_Animations array, so we don't need to add it
            // Unity's GetClip() can be unreliable, so we'll use the default clip directly
            if (valveAnimation.clip != null)
            {
                AnimationClip clip = valveAnimation.clip;
                string clipName = clip.name;
                
                Debug.Log($"Default clip found: '{clipName}'");
                
                // Try to access the AnimationState - this will create it if it doesn't exist
                // The clip is already in the m_Animations array from the scene, so the state should be accessible
                try
                {
                    // Accessing the state by name will create it if the clip is in the animations array
                    AnimationState state = valveAnimation[clipName];
                    if (state != null)
                    {
                        Debug.Log($"AnimationState for '{clipName}' is accessible");
                        // Set wrap mode now so it's ready when we play
                        state.wrapMode = WrapMode.Once;
                    }
                    else
                    {
                        Debug.LogWarning($"AnimationState for '{clipName}' is null - clip may not be in animations array");
                    }
                }
                catch (System.Exception e)
                {
                    Debug.LogWarning($"Could not access AnimationState for '{clipName}': {e.Message}");
                    Debug.LogWarning("This is normal if the clip isn't in the animations array yet. It will be handled at play time.");
                }
            }
            
            Debug.Log($"Animation component configured - Clip: {(valveAnimation.clip != null ? valveAnimation.clip.name : "None")}, Enabled: {valveAnimation.enabled}, Play Automatically: {valveAnimation.playAutomatically}");
        }
        else
        {
            Debug.LogWarning("No Animation component found on valve!");
        }
        
        // Find player camera
        playerCamera = Camera.main;
        if (playerCamera != null)
        {
            playerController = playerCamera.GetComponentInParent<FPController>();
        }
        
        // Try to find water particle system automatically if not assigned
        if (waterFlow == null)
        {
            // Look for particle system in children or nearby
            waterFlow = GetComponentInChildren<ParticleSystem>();
            if (waterFlow == null)
            {
                // Look in parent or siblings
                ParticleSystem[] allPS = FindObjectsOfType<ParticleSystem>();
                foreach (ParticleSystem ps in allPS)
                {
                    // Check if it's near the valve (within 5 units)
                    if (Vector3.Distance(ps.transform.position, transform.position) < 5f)
                    {
                        waterFlow = ps;
                        Debug.Log($"Auto-found water particle system: {ps.name}");
                        break;
                    }
                }
            }
            else
            {
                Debug.Log($"Auto-found water particle system in children: {waterFlow.name}");
            }
        }
        
        // Initialize water flow state - ensure it's completely stopped
        if (waterFlow != null)
        {
            waterFlow.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear); // Stop and clear all particles
            waterFlow.Clear(); // Clear any existing particles
            waterIsFlowing = false;
            Debug.Log("Water particle system initialized and stopped.");
        }
        else
        {
            Debug.LogError("Water Flow particle system not found! Please assign it in the Inspector or place it near the valve.");
        }
    }
    
    void Update()
    {
        // Check if an animation is currently playing (Legacy Animation)
        bool animationIsPlaying = false;
        if (valveAnimation != null && valveAnimation.isPlaying)
        {
            animationIsPlaying = true;
        }
        
        // Check if Animator is playing a state
        if (!animationIsPlaying && valveAnimator != null && valveAnimator.enabled)
        {
            if (valveAnimator.GetCurrentAnimatorStateInfo(0).IsName(spinAnimationName) || 
                valveAnimator.GetCurrentAnimatorStateInfo(0).IsTag("Spin"))
            {
                // If it's playing and normalized time is < 1, checking if it is still playing
                 if(valveAnimator.GetCurrentAnimatorStateInfo(0).normalizedTime < 1.0f) {
                     animationIsPlaying = true;
                 }
            }
        }
        
        // Handle code-based rotation animation (only if no animation is playing)
        if (isRotating && !animationIsPlaying)
        {
            float targetRotation = isOpen ? openRotation : 0f;
            
            // Use LerpAngle for smooth rotation that handles wrapping correctly
            currentRotation = Mathf.LerpAngle(currentRotation, targetRotation, rotationSpeed * Time.deltaTime);
            
            // Check if we're close enough to target (within 1 degree)
            if (Mathf.Abs(Mathf.DeltaAngle(currentRotation, targetRotation)) < 1f)
            {
                currentRotation = targetRotation;
                isRotating = false;
            }
            
            if (valveHandle != null)
            {
                // Rotate around the local Z axis (the axis pointing out from the valve wheel)
                // This is the correct axis for a valve wheel rotation
                // We multiply the initial rotation by the rotation offset to preserve the original orientation
                Quaternion rotationOffset = Quaternion.Euler(0, 0, currentRotation);
                valveHandle.localRotation = initialRotation * rotationOffset;
            }
        }
        // If animation finished, stop the rotation flag
        if (isRotating && animationIsPlaying)
        {
            // Logic handled by the fact that animationIsPlaying will become false when done
        }
        
        // Check for interaction
        if (Input.GetKeyDown(interactKey))
        {
            if (IsPlayerLookingAtValve())
            {
                ToggleValve();
            }
        }
    }
    
    bool IsPlayerLookingAtValve()
    {
        if (playerCamera == null) return false;
        
        RaycastHit hit;
        Vector3 rayOrigin = playerCamera.transform.position;
        Vector3 rayDirection = playerCamera.transform.forward;
        
        if (Physics.Raycast(rayOrigin, rayDirection, out hit, interactionDistance))
        {
            // Check if we hit this valve or any of its children
            if (hit.transform == transform || hit.transform.IsChildOf(transform))
            {
                return true;
            }
        }
        
        return false;
    }
    
    public void ToggleValve()
    {
        isOpen = !isOpen;
        isRotating = true;
        
        Debug.Log($"ToggleValve called - isOpen: {isOpen}, Animation component: {(valveAnimation != null ? "Found" : "NULL")}, Clip: {(valveAnimation != null && valveAnimation.clip != null ? valveAnimation.clip.name : "None")}");
        
        // Play spin animation if available
        PlaySpinAnimation();
        
        Debug.Log($"ToggleValve called - isOpen: {isOpen}, waterFlow is null: {waterFlow == null}");
        
        // Try to find water flow if still null
        if (waterFlow == null)
        {
            waterFlow = GetComponentInChildren<ParticleSystem>();
            if (waterFlow == null)
            {
                ParticleSystem[] allPS = FindObjectsOfType<ParticleSystem>();
                foreach (ParticleSystem ps in allPS)
                {
                    if (Vector3.Distance(ps.transform.position, transform.position) < 5f)
                    {
                        waterFlow = ps;
                        Debug.Log($"Found water particle system: {ps.name}");
                        break;
                    }
                }
            }
        }
        
        // Start or stop water flow - toggle on/off
        if (waterFlow != null)
        {
            if (isOpen)
            {
                // Start water flow
                waterFlow.Play();
                waterIsFlowing = true;
                Debug.Log($"Valve opened - Water flowing! Particle system '{waterFlow.name}' is now playing.");
            }
            else
            {
                // Stop water flow completely
                waterFlow.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                waterFlow.Clear(); // Clear all particles immediately
                waterIsFlowing = false;
                Debug.Log("Valve closed - Water stopped!");
            }
        }
        else
        {
            Debug.LogError("Water Flow particle system is not assigned and could not be found automatically! Please assign it in the Inspector.");
        }
        
        // Play water sound if available
        if (waterSound != null)
        {
            if (isOpen)
            {
                if (!waterSound.isPlaying)
                {
                    waterSound.Play();
                }
            }
            else
            {
                waterSound.Stop();
            }
        }
    }
    
    // Public method to check if valve is open (for other scripts)
    public bool IsOpen()
    {
        return isOpen;
    }
    
    // Ensure water doesn't play on scene start
    void Awake()
    {
        if (waterFlow != null)
        {
            waterFlow.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
            waterFlow.Clear();
            waterIsFlowing = false;
        }
        
        // We don't disable Animator anymore
        
        if (valveAnimation != null)
        {
            valveAnimation.playAutomatically = false;
            valveAnimation.Stop();
        }
    }
    
    // Play the spin animation
    private void PlaySpinAnimation()
    {
        bool animationPlaying = false;
        
        // STRATEGY 1: Try Legacy Animation Component
        if (valveAnimation != null && valveAnimation.enabled)
        {
            // Stop any currently playing animation first
            valveAnimation.Stop();
            
            // Determine which animation to play
            string targetName = !string.IsNullOrEmpty(spinAnimationName) ? spinAnimationName : null;
            
            // If no specific name, try to use the default clip's name
            if (targetName == null && valveAnimation.clip != null)
            {
                targetName = valveAnimation.clip.name;
            }
            
            Debug.Log($"Looking for animation: {targetName ?? "any"}");
            
            // Try to play using Play()
            try
            {
                if (targetName != null) {
                    valveAnimation.Play(targetName);
                } else {
                    valveAnimation.Play();
                }
                
                if (valveAnimation.isPlaying) {
                     animationPlaying = true;
                     Debug.Log($"Played Legacy Animation: {targetName ?? "default"}");
                }
            } catch (System.Exception e) {
                Debug.LogWarning($"Legacy animation failed: {e.Message}");
            }
            
            if (!animationPlaying && valveAnimation.clip != null) {
                 // Try crossfade fallback
                 try {
                     valveAnimation.CrossFade(valveAnimation.clip.name);
                     if (valveAnimation.isPlaying) animationPlaying = true;
                 } catch {}
            }
        }
        
        // STRATEGY 2: Try Modern Animator Component (Fallback)
        if (!animationPlaying && valveAnimator != null)
        {
            Debug.Log("Legacy animation failed or missing. Trying Animator component...");
            
            // Force enable if disabled
            if (!valveAnimator.enabled)
            {
                Debug.Log("Animator component was disabled. Enabling it now for fallback.");
                valveAnimator.enabled = true;
            }

            // If we have a name, try to play state by name
            if (!string.IsNullOrEmpty(spinAnimationName))
            {
                // We can't easily know if the state exists without trying
                valveAnimator.Play(spinAnimationName, 0, 0f);
                // We'll assume it works if the Trigger/Play command was sent. 
                // Actual checking happens in Update loop
                animationPlaying = true; 
                Debug.Log($"Triggered Animator with state: {spinAnimationName}");
            }
            else
            {
                // Try to just trigger "Spin" or similar common names if defined?
                // Or maybe the user set up a Trigger parameter. 
                // For now, let's assume 'Spin' is the state name as defined in inspector.
                 valveAnimator.Play("Spin", 0, 0f);
                 animationPlaying = true;
            }
        }
        
        // If neither worked, we rely on code-based rotation in Update()
        if (!animationPlaying)
        {
            Debug.LogWarning($"Could not play animation via Legacy or Animator. Using code-based rotation.");
        }
    }
    
    // Called when player looks at valve (optional UI prompt)
    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(transform.position, interactionDistance);
    }
}

