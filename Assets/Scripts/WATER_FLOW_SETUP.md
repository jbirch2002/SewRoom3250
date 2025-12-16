# Water Flow Setup Guide

## Quick Setup Steps

### 1. Create the Particle System for Water

1. **In Unity, select your SewerPipe object** (or create an empty GameObject at the pipe exit)
2. **Right-click → Effects → Particle System**
3. **Name it "WaterFlow"**

### 2. Configure the Particle System

Select the WaterFlow particle system and configure these settings:

#### Main Module:
- **Start Lifetime**: 2-3 seconds
- **Start Speed**: 3-5
- **Start Size**: 0.1-0.3
- **Start Color**: Dark gray/blue (e.g., R: 0.2, G: 0.3, B: 0.4, A: 0.8)
- **Max Particles**: 1000

#### Emission:
- **Rate over Time**: 50-100 (adjust for flow intensity)

#### Shape:
- **Shape**: Cone or Box
- **Angle**: 5-15 degrees (for cone) or adjust box size
- **Radius/Box Size**: Match your pipe opening size
- **Rotation**: Point down/forward along pipe direction

#### Velocity over Lifetime:
- Enable this module
- **Space**: Local
- **Z**: 3-5 (forward velocity)
- **Y**: -2 to -5 (downward gravity effect)

#### Color over Lifetime:
- Enable this module
- Set gradient from darker at start to slightly lighter
- Alpha: Start at 0.8, fade to 0 at end

#### Size over Lifetime:
- Enable this module
- Curve: Start small, grow slightly, then shrink

#### Renderer:
- **Render Mode**: Mesh (for better water look) or Billboard
- **Material**: Create a simple water material (semi-transparent blue/gray)

### 3. Position the Particle System

- Position it at the **exit/opening of your sewer pipe**
- Rotate it so particles flow in the direction you want
- Make it a child of the pipe or valve object

### 4. Set Up the Valve Script

1. **Select your Valve GameObject** in the scene
2. **Add Component → ValveController** (the script we created)
3. **In the Inspector, assign:**
   - **Water Flow**: Drag your WaterFlow particle system here
   - **Water Sound** (optional): Add an AudioSource component and assign a water sound clip
   - **Interact Key**: Set to E (or your preferred key)
   - **Interaction Distance**: 3 (how close player needs to be)

### 5. Configure Valve Handle Rotation (Optional)

If your valve has a rotating handle:
- Assign the rotating part to **Valve Handle** field
- Set **Open Rotation**: 360 (or how many degrees to rotate)
- Set **Rotation Speed**: 90 (degrees per second)

### 6. Test It!

1. **Enter Play Mode**
2. **Look at the valve** (within interaction distance)
3. **Press E** to toggle the valve
4. **Water should start flowing** from the pipe!

## Tips

- **Adjust particle count and emission rate** to match your desired flow intensity
- **Use a simple water shader/material** for better visual quality
- **Add a water sound effect** for audio feedback
- **Position the particle system** so it looks like it's coming from inside the pipe
- **You can duplicate the particle system** for multiple pipe exits

## Alternative: Simple Animated Material

If you prefer a simpler approach without particles:
1. Create a plane/mesh at the pipe opening
2. Use an animated water texture/material
3. Enable/disable the GameObject when valve is toggled

The particle system approach gives better visual results for flowing water!

