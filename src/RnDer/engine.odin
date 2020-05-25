package RnDer

EngineCallback :: proc(^Engine);
UpdateWindowTitle :: proc();
PrintDebugString :: proc(cstring);
GetTicks :: proc() -> u64;

Viewport :: struct {
    controller: ^Controller,
    renderer: ^Renderer,
    camera: ^Camera
};

Engine :: struct {
    updateWindowTitle: UpdateWindowTitle,
    printDebugString: PrintDebugString,

    controllers: struct {
        fps: ^FpsController,
        orb: ^OrbController
    },
    renderers: struct {
        ray_tracer: ^RayTracer,
        ray_caster: ^RayCaster
    },
    
    frame_buffer: ^FrameBuffer,
    active_viewport: ^Viewport,
    scene: ^Scene,
    
    perf: ^Perf,
    hud: ^HUD,

    mouse: ^Mouse,
    keyboard: ^Keyboard,

    is_running: bool
};

resize :: inline proc(using engine: ^Engine) {
    active_viewport.renderer.on.resize(engine);
    updateHUDDimensions(hud, frame_buffer.width, frame_buffer.height);
}

updateAndRender :: proc(using engine: ^Engine) {
    startFramePerf(perf);

    using active_viewport;

    if mouse.wheel.changed {
        mouse.wheel.changed = false;
        controller.on.mouseScrolled(engine);
        mouse.wheel.scroll = 0;
    }

    if mouse.coords.relative.changed {
        mouse.coords.relative.changed = false;
        controller.on.mouseMoved(engine);
        mouse.coords.relative.x = 0;
        mouse.coords.relative.y = 0;
    }

    controller.on.update(engine);

    if controller.changed.zoom {
        controller.changed.zoom = false;
        renderer.on.zoom(engine);
    }

    if controller.changed.orientation {
        controller.changed.orientation = false;
        renderer.on.rotate(engine);
    }

    if controller.changed.position {
        controller.changed.position = false;
        renderer.on.move(engine);
    }

    renderer.on.render(engine);

    endFramePerf(perf);
    if hud.is_visible {
        updateHUDZoom(hud, controller.zoom_amount);
        if perf.accum.frames != 0 do updateHUDCounters(hud, perf);
        drawText(hud.text, hud.pixel, frame_buffer.width - HUD_RIGHT - HUD_WIDTH, HUD_TOP, frame_buffer);
    }

//    if (buttons.first.is_pressed) engine.renderer = &ray_tracer.renderer;
//    if (buttons.second.is_pressed) engine.renderer = &ray_caster.base;

    if keyboard.hud.is_pressed {
        keyboard.hud.is_pressed = false;
        hud.is_visible = !hud.is_visible;
    }

    if mouse.double_clicked {
        mouse.double_clicked = false;
        is_fps: = controller == &controllers.fps.controller;
        active_viewport.controller = is_fps ? &controllers.orb.controller : &controllers.fps.controller;
        setControllerModeInHUD(hud, !is_fps);
    }
}

createEngine :: proc(
    updateWindowTitleCB: UpdateWindowTitle,
    printDebugStringCB: PrintDebugString,
    getTicksCB: GetTicks,
    ticks_per_second: u64
) -> ^Engine {
    engine := Alloc(Engine);
    using engine;
    is_running = true;

    printDebugString = printDebugStringCB;
    updateWindowTitle = updateWindowTitleCB;

    mouse = createMouse();
    keyboard = createKeyboard();

    hud = createHUD();
    hud.debug_perf = createPerf(getTicksCB, ticks_per_second);
    perf = createPerf(getTicksCB, ticks_per_second);
    
    scene = createScene();
    frame_buffer = createFrameBuffer();
    
    controllers.fps = createFpsController(scene.camera);
    controllers.orb = createOrbController(scene.camera);

    renderers.ray_tracer = createRayTracer(engine);
    renderers.ray_caster = createRayCaster(engine);

    active_viewport = Alloc(Viewport);
    active_viewport.controller = &controllers.orb.controller;
    active_viewport.renderer = renderers.ray_tracer;

    scene.camera.transform.position.x = 5;
    scene.camera.transform.position.y = 5;
    scene.camera.transform.position.z = -10;

    active_viewport.controller.changed.position = true;

    return engine;
}