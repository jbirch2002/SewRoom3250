using UnityEngine;

/// <summary>
/// Helper script to automatically configure a particle system for sewer water flow.
/// Attach this to your particle system GameObject - it will configure automatically on Start.
/// You can remove this script after it runs once.
/// </summary>
[RequireComponent(typeof(ParticleSystem))]
public class WaterParticleSetup : MonoBehaviour
{
    [SerializeField] private bool autoSetupOnStart = true;
    
    void Start()
    {
        if (autoSetupOnStart)
        {
            SetupWaterParticles();
        }
    }
    
    [ContextMenu("Setup Water Particles")]
    public void SetupWaterParticles()
    {
        ParticleSystem ps = GetComponent<ParticleSystem>();
        if (ps == null)
        {
            Debug.LogError("No ParticleSystem found!");
            return;
        }

        var main = ps.main;
        var emission = ps.emission;
        var shape = ps.shape;
        var velocityOverLifetime = ps.velocityOverLifetime;
        var colorOverLifetime = ps.colorOverLifetime;
        var sizeOverLifetime = ps.sizeOverLifetime;
        var renderer = ps.GetComponent<ParticleSystemRenderer>();

        // Main Module
        main.startLifetime = 2f; // Shorter lifetime for faster flow
        main.startSpeed = 0f; // No initial speed - let velocity over lifetime handle it
        main.startSize = 0.1f; // Smaller particles
        main.startColor = new Color(0.2f, 0.8f, 0.3f, 0.9f); // Caustic radioactive green
        main.maxParticles = 2000; // More particles for continuous flow
        main.simulationSpace = ParticleSystemSimulationSpace.Local;
        main.playOnAwake = false; // Don't start until valve is opened
        ps.Stop(); // Ensure it's stopped initially
        ps.Clear(); // Clear any existing particles
        main.startRotation = 0f;
        main.startRotation3D = false;
        main.gravityModifier = 1.5f; // Extra gravity to pull water down

        // Emission - Higher rate for continuous flow
        emission.enabled = true;
        emission.rateOverTime = 150f; // Doubled for better flow continuity

        // Shape - Circle pointing straight down
        shape.enabled = true;
        shape.shapeType = ParticleSystemShapeType.Circle; // Circle matches pipe opening better
        shape.radius = 0.15f; // Match your pipe inner radius
        shape.radiusThickness = 0f; // Solid circle, not ring
        shape.arc = 360f;
        shape.rotation = new Vector3(0f, 0f, 0f); // Point straight down (no rotation)

        // Velocity over Lifetime - ONLY downward, no sideways motion
        velocityOverLifetime.enabled = true;
        velocityOverLifetime.space = ParticleSystemSimulationSpace.Local;
        velocityOverLifetime.x = new ParticleSystem.MinMaxCurve(0f); // No horizontal movement
        velocityOverLifetime.y = new ParticleSystem.MinMaxCurve(-5f); // Straight down
        velocityOverLifetime.z = new ParticleSystem.MinMaxCurve(0f); // No forward movement

        // Color over Lifetime - toxic green with slight glow
        colorOverLifetime.enabled = true;
        Gradient gradient = new Gradient();
        gradient.SetKeys(
            new GradientColorKey[] { 
                new GradientColorKey(new Color(0.15f, 0.9f, 0.25f, 0.95f), 0.0f), // Bright toxic green
                new GradientColorKey(new Color(0.2f, 0.8f, 0.3f, 0.8f), 0.3f), // Slightly dimmer
                new GradientColorKey(new Color(0.25f, 0.7f, 0.35f, 0.5f), 0.7f), // Fading
                new GradientColorKey(new Color(0.3f, 0.6f, 0.4f, 0f), 1.0f) // Fade out
            },
            new GradientAlphaKey[] { 
                new GradientAlphaKey(0.95f, 0.0f),
                new GradientAlphaKey(0.85f, 0.3f),
                new GradientAlphaKey(0.6f, 0.7f),
                new GradientAlphaKey(0f, 1.0f)
            }
        );
        colorOverLifetime.color = gradient;

        // Size over Lifetime - smoother size variation
        sizeOverLifetime.enabled = true;
        AnimationCurve sizeCurve = new AnimationCurve();
        sizeCurve.AddKey(0f, 0.9f); // Start at 90% size
        sizeCurve.AddKey(0.2f, 1.1f); // Grow slightly
        sizeCurve.AddKey(0.8f, 1.0f); // Maintain size
        sizeCurve.AddKey(1f, 0.4f); // Shrink at end
        // Smooth the curve for less blocky look
        for (int i = 0; i < sizeCurve.length; i++)
        {
            sizeCurve.SmoothTangents(i, 0.5f);
        }
        sizeOverLifetime.size = new ParticleSystem.MinMaxCurve(1f, sizeCurve);

        // Disable trails - they were causing the "rave" effect
        var trails = ps.trails;
        trails.enabled = false;
        
        // Renderer - simple billboard for clean water flow
        if (renderer != null)
        {
            renderer.renderMode = ParticleSystemRenderMode.Billboard; // Simple billboard, no stretching
            renderer.sortingFudge = -1f; // Render behind geometry slightly
            renderer.sortingOrder = 0; // Lower sorting order
            
            // Create a toxic green water material
            if (renderer.material == null || renderer.material.name.Contains("Default"))
            {
                Material waterMat = new Material(Shader.Find("Standard"));
                waterMat.name = "ToxicWaterParticleMaterial";
                waterMat.SetFloat("_Metallic", 0f);
                waterMat.SetFloat("_Glossiness", 0.4f);
                waterMat.SetColor("_Color", new Color(0.2f, 0.8f, 0.3f, 0.8f)); // Toxic green
                waterMat.SetFloat("_Mode", 3); // Transparent mode
                waterMat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                waterMat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                waterMat.SetInt("_ZWrite", 0);
                waterMat.DisableKeyword("_ALPHATEST_ON");
                waterMat.EnableKeyword("_ALPHABLEND_ON");
                waterMat.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                waterMat.renderQueue = 3000;
                
                // Add slight emission for toxic glow
                waterMat.EnableKeyword("_EMISSION");
                waterMat.SetColor("_EmissionColor", new Color(0.1f, 0.4f, 0.15f, 1f) * 0.5f);
                
                renderer.material = waterMat;
            }
        }

        // Gravity - strong downward force
        var forceOverLifetime = ps.forceOverLifetime;
        forceOverLifetime.enabled = true;
        forceOverLifetime.space = ParticleSystemSimulationSpace.World;
        forceOverLifetime.x = 0f; // No horizontal force
        forceOverLifetime.y = -4f; // Strong downward force
        forceOverLifetime.z = 0f; // No forward/back force
        
        // Disable noise - we want straight down flow, not chaotic
        var noise = ps.noise;
        noise.enabled = false;
        
        // Collision - kill particles when they hit pipe walls
        var collision = ps.collision;
        collision.enabled = true;
        collision.type = ParticleSystemCollisionType.World; // Collide with world geometry
        collision.mode = ParticleSystemCollisionMode.Collision3D;
        collision.quality = ParticleSystemCollisionQuality.High;
        collision.lifetimeLoss = 1f; // Kill particles immediately on collision
        collision.dampen = 0f; // No bouncing
        collision.bounce = 0f;
        collision.lifetimeLossMultiplier = 1f;
        collision.sendCollisionMessages = false;

        Debug.Log("Water particle system configured! You can now remove this WaterParticleSetup script.");
    }
}

