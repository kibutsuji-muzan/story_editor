// Core Models
export 'src/core/models/editor_layer.dart';
export 'src/core/models/transform_data.dart';
export 'src/core/models/editor_state.dart';
export 'src/features/text/text_layer.dart';
export 'src/features/image/image_layer.dart';
export 'src/features/sticker/sticker_layer.dart';
export 'src/features/timer/timer_layer.dart';
export 'src/features/polls/polls_layer.dart';
export 'src/features/music/music_layer.dart';

// Core Controllers
export 'src/core/controllers/story_editor_controller.dart';
export 'src/core/controllers/history_controller.dart';
export 'src/core/controllers/selection_controller.dart';

// Core Services
export 'src/core/services/serialization_service.dart';
export 'src/core/services/export_service.dart';
export 'src/core/services/gesture_service.dart';
export 'src/core/services/history_service.dart';

// Constants & Utilities
export 'src/core/constants/editor_defaults.dart';
export 'src/core/constants/editor_limits.dart';
export 'src/core/utils/matrix_utils.dart';
export 'src/core/utils/export_utils.dart';
export 'src/core/utils/layer_utils.dart';

// Main Editor Viewport & Widgets
export 'src/editor/story_editor.dart';
export 'src/editor/story_canvas.dart';
export 'src/editor/editor_toolbar.dart';
export 'src/editor/editor_overlay.dart';
export 'src/layers/widgets/layer_frame.dart';

// Renderers & Interactions
export 'src/layers/renderers/layer_renderer.dart';
export 'src/layers/renderers/text_renderer.dart';
export 'src/layers/renderers/image_renderer.dart';
export 'src/layers/interactions/draggable_layer.dart';
export 'src/layers/interactions/scalable_layer.dart';
export 'src/layers/interactions/rotatable_layer.dart';

// Animations Engine
export 'src/animations/animation_engine.dart';
export 'src/animations/animation_models.dart';
export 'src/animations/presets/fade_animation.dart';
export 'src/animations/presets/slide_animation.dart';
export 'src/animations/presets/scale_animation.dart';

// Plugins Interface & Registry
export 'src/plugins/editor_plugin.dart';
export 'src/plugins/plugin_registry.dart';
export 'src/features/image/image_plugin.dart';
export 'src/features/music/music_plugin.dart';
export 'src/features/polls/polls_plugin.dart';
export 'src/features/sticker/sticker_plugin.dart';
export 'src/features/text/text_plugin.dart';
export 'src/features/timer/timer_plugin.dart';

// Exporters & Pipeline
export 'src/export/image_exporter.dart';
export 'src/export/video_exporter.dart';
export 'src/export/render_pipeline.dart';

// Themes
export 'src/themes/editor_theme.dart';
export 'src/themes/toolbar_theme.dart';
export 'src/themes/canvas_theme.dart';

// Extensions
export 'extensions/color_extensions.dart';
export 'extensions/context_extensions.dart';
