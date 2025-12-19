using UnityEngine;

/// <summary>
/// Attach this to a GameObject (child of your Water Plane) to automatically configure 
/// a Particle System that looks like floating sewer debris.
/// </summary>
[RequireComponent(typeof(ParticleSystem))]
public class FloatingDebrisSetup : MonoBehaviour
{
    [SerializeField] private bool autoSetupOnStart = true;

    void Start()
    {
        if (autoSetupOnStart)
        {
            SetupDebris();
        }
    }

    [ContextMenu("Setup Debris Particles")]
    public void SetupDebris()
    {
        ParticleSystem ps = GetComponent<ParticleSystem>();
        
        // Modules
        var main = ps.main;
        var emission = ps.emission;
        var shape = ps.shape;
        var velocityOverLifetime = ps.velocityOverLifetime;
        var noise = ps.noise;
        var renderer = ps.GetComponent<ParticleSystemRenderer>();
        var colorOverLifetime = ps.colorOverLifetime;

        // 1. Main Settings
        main.startLifetime = 10f; // Long life for floating debris
        main.startSpeed = 0.2f;   // Very slow initial movement
        main.startSize = new ParticleSystem.MinMaxCurve(0.1f, 0.4f); // Random sizes
        main.maxParticles = 100;
        main.simulationSpace = ParticleSystemSimulationSpace.World; // Move with world/up independent of parent slightly, or World allows complex noise
        // Actually, if we want them to rise with the water plane, Local space is better IF this object is a child of the water plane.
        // Let's assume user parents this to the water plane.
        main.simulationSpace = ParticleSystemSimulationSpace.Local; 
        
        main.startColor = new Color(0.3f, 0.2f, 0.1f, 1f); // Brownish/Dark
        main.loop = true;

        // 2. Emission
        emission.rateOverTime = 5f; // Constant trickle of new items if needed, or bursts.
        // Actually, for a pool, we might want Prewarm so they describe the whole surface immediately?
        // But Prewarm only works if loop is on.
        main.prewarm = false; // Turn on manually if desired, but might glitch with rising water.

        // 3. Shape - A box describing the water surface volume
        shape.enabled = true;
        shape.shapeType = ParticleSystemShapeType.Box;
        shape.scale = new Vector3(5f, 0.5f, 5f); // 5x5 area, shallow depth
        // User should adjust Scale on the Transform to match room size.

        // 4. Noise - The key for "Floating" behavior
        noise.enabled = true;
        noise.strength = 0.5f;       // Gentle drift
        noise.frequency = 0.3f;      // Slow changes
        noise.scrollSpeed = 0.2f;    // Scroll noise over time
        noise.damping = true;
        
        // 5. Velocity - Gentle drift
        velocityOverLifetime.enabled = true;
        velocityOverLifetime.x = new ParticleSystem.MinMaxCurve(-0.1f, 0.1f);
        velocityOverLifetime.z = new ParticleSystem.MinMaxCurve(-0.1f, 0.1f);
        velocityOverLifetime.y = new ParticleSystem.MinMaxCurve(-0.05f, 0.05f); // Slight bobbing

        // 6. Color Over Lifetime - Fade in/out
        colorOverLifetime.enabled = true;
        Gradient grad = new Gradient();
        grad.SetKeys(
            new GradientColorKey[] { new GradientColorKey(new Color(0.2f, 0.15f, 0.05f), 0f), new GradientColorKey(new Color(0.1f, 0.1f, 0.1f), 1f) },
            new GradientAlphaKey[] { new GradientAlphaKey(0f, 0f), new GradientAlphaKey(1f, 0.2f), new GradientAlphaKey(1f, 0.8f), new GradientAlphaKey(0f, 1f) }
        );
        colorOverLifetime.color = grad;

        // 7. Renderer
        if (renderer != null)
        {
            renderer.renderMode = ParticleSystemRenderMode.Billboard;
            renderer.material = new Material(Shader.Find("Sprites/Default")); // Simple default sprite
            renderer.material.color = new Color(0.4f, 0.35f, 0.15f, 0.9f); // Darker muddy color
        }
        
        // 8. Collision - High Quality + Specific Plane Collision
        var collision = ps.collision;
        collision.enabled = true;
        collision.type = ParticleSystemCollisionType.World;
        collision.mode = ParticleSystemCollisionMode.Collision3D;
        
        // Return to High quality for accuracy, but limit budget to prevent flakes/leaks
        collision.quality = ParticleSystemCollisionQuality.High; 
        collision.maxCollisionShapes = 128; // Reduce from default 256 to save memory
        
        collision.lifetimeLoss = 1.0f; // Die on impact
        
        // Collide with everything EXCEPT TransparentFX (Grate)
        collision.collidesWith = ~LayerMask.GetMask("TransparentFX", "Ignore Raycast"); 
        
        // Add a small radius to particles to prevent tunneling
        collision.radiusScale = 1.5f; // Fat particles collide better
        
        Debug.Log("Debris Particles Configured. Ensure your 'Grate' is on 'TransparentFX' layer and Floor has Colliders!");
    }
}
