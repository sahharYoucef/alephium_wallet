// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:alephium_wallet/routes/wallet_details/widgets/shake_widget.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShakeForm extends StatefulWidget {
  /// Creates a container for form fields.
  ///
  /// The [child] argument must not be null.
  const ShakeForm({
    super.key,
    required this.child,
    this.onWillPop,
    this.onChanged,
    AutovalidateMode? autovalidateMode,
  })  : assert(child != null),
        autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled;

  /// Returns the closest [ShakeFormState] which encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// FormState form = Form.of(context);
  /// form.save();
  /// ```
  static ShakeFormState? of(BuildContext context) {
    final _FormScope? scope =
        context.dependOnInheritedWidgetOfExactType<_FormScope>();
    return scope?._formState;
  }

  /// The widget below this widget in the tree.
  ///
  /// This is the root of the widget hierarchy that contains this form.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Enables the form to veto attempts by the user to dismiss the [ModalRoute]
  /// that contains the form.
  ///
  /// If the callback returns a Future that resolves to false, the form's route
  /// will not be popped.
  ///
  /// See also:
  ///
  ///  * [WillPopScope], another widget that provides a way to intercept the
  ///    back button.
  final WillPopCallback? onWillPop;

  /// Called when one of the form fields changes.
  ///
  /// In addition to this callback being invoked, all the form fields themselves
  /// will rebuild.
  final VoidCallback? onChanged;

  /// Used to enable/disable form fields auto validation and update their error
  /// text.
  ///
  /// {@macro flutter.widgets.FormField.autovalidateMode}
  final AutovalidateMode autovalidateMode;

  @override
  ShakeFormState createState() => ShakeFormState();
}

class ShakeFormState extends State<ShakeForm> {
  int _generation = 0;
  bool _hasInteractedByUser = false;
  final Set<_FormFieldState<dynamic>> _fields = <_FormFieldState<dynamic>>{};

  // Called when a form field has changed. This will cause all form fields
  // to rebuild, useful if form fields have interdependencies.
  void _fieldDidChange() {
    widget.onChanged?.call();

    _hasInteractedByUser = _fields.any(
        (_FormFieldState<dynamic> field) => field._hasInteractedByUser.value);
    _forceRebuild();
  }

  void _forceRebuild() {
    setState(() {
      ++_generation;
    });
  }

  void _register(_FormFieldState<dynamic> field) {
    _fields.add(field);
  }

  void _unregister(_FormFieldState<dynamic> field) {
    _fields.remove(field);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.autovalidateMode) {
      case AutovalidateMode.always:
        _validate();
        break;
      case AutovalidateMode.onUserInteraction:
        if (_hasInteractedByUser) {
          _validate();
        }
        break;
      case AutovalidateMode.disabled:
        break;
    }

    return WillPopScope(
      onWillPop: widget.onWillPop,
      child: _FormScope(
        formState: this,
        generation: _generation,
        child: widget.child,
      ),
    );
  }

  /// Saves every [_FormField] that is a descendant of this [ShakeForm].
  void save() {
    for (final _FormFieldState<dynamic> field in _fields) {
      field.save();
    }
  }

  /// Resets every [_FormField] that is a descendant of this [ShakeForm] back to its
  /// [_FormField.initialValue].
  ///
  /// The [ShakeForm.onChanged] callback will be called.
  ///
  /// If the form's [ShakeForm.autovalidateMode] property is [AutovalidateMode.always],
  /// the fields will all be revalidated after being reset.
  void reset() {
    for (final _FormFieldState<dynamic> field in _fields) {
      field.reset();
    }
    _hasInteractedByUser = false;
    _fieldDidChange();
  }

  /// Validates every [_FormField] that is a descendant of this [ShakeForm], and
  /// returns true if there are no errors.
  ///
  /// The form will rebuild to report the results.
  bool validate({bool shake = false}) {
    _hasInteractedByUser = true;
    _forceRebuild();
    return _validate(shake: shake);
  }

  bool _validate({bool shake = false}) {
    bool hasError = false;
    for (final _FormFieldState<dynamic> field in _fields) {
      hasError = !field.validate(shake: shake) || hasError;
    }
    return !hasError;
  }
}

class _FormScope extends InheritedWidget {
  const _FormScope({
    required super.child,
    required ShakeFormState formState,
    required int generation,
  })  : _formState = formState,
        _generation = generation;

  final ShakeFormState _formState;

  /// Incremented every time a form field has changed. This lets us know when
  /// to rebuild the form.
  final int _generation;

  /// The [ShakeForm] associated with this widget.
  ShakeForm get form => _formState.widget;

  @override
  bool updateShouldNotify(_FormScope old) => _generation != old._generation;
}

/// Signature for validating a form field.
///
/// Returns an error string to display if the input is invalid, or null
/// otherwise.
///
/// Used by [_FormField.validator].
typedef FormFieldValidator<T> = String? Function(T? value);

/// Signature for being notified when a form field changes value.
///
/// Used by [_FormField.onSaved].
typedef FormFieldSetter<T> = void Function(T? newValue);

/// Signature for building the widget representing the form field.
///
/// Used by [_FormField.builder].
typedef FormFieldBuilder<T> = Widget Function(_FormFieldState<T> field);

/// A single form field.
///
/// This widget maintains the current state of the form field, so that updates
/// and validation errors are visually reflected in the UI.
///
/// When used inside a [ShakeForm], you can use methods on [ShakeFormState] to query or
/// manipulate the form data as a whole. For example, calling [ShakeFormState.save]
/// will invoke each [_FormField]'s [onSaved] callback in turn.
///
/// Use a [GlobalKey] with [_FormField] if you want to retrieve its current
/// state, for example if you want one form field to depend on another.
///
/// A [ShakeForm] ancestor is not required. The [ShakeForm] simply makes it easier to
/// save, reset, or validate multiple fields at once. To use without a [ShakeForm],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// See also:
///
///  * [ShakeForm], which is the widget that aggregates the form fields.
///  * [TextField], which is a commonly used form field for entering text.
class _FormField<T> extends StatefulWidget {
  /// Creates a single form field.
  ///
  /// The [builder] argument must not be null.
  const _FormField({
    super.key,
    required this.builder,
    this.onSaved,
    this.validator,
    this.initialValue,
    this.enabled = true,
    this.errorStyle,
    AutovalidateMode? autovalidateMode,
    this.restorationId,
  })  : assert(builder != null),
        autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled;

  /// An optional method to call with the final value when the form is saved via
  /// [ShakeFormState.save].
  final FormFieldSetter<T>? onSaved;

  final TextStyle? errorStyle;

  /// An optional method that validates an input. Returns an error string to
  /// display if the input is invalid, or null otherwise.
  ///
  /// The returned value is exposed by the [_FormFieldState.errorText] property.
  /// The [TextFormField] uses this to override the [InputDecoration.errorText]
  /// value.
  ///
  /// Alternating between error and normal state can cause the height of the
  /// [TextFormField] to change if no other subtext decoration is set on the
  /// field. To create a field whose height is fixed regardless of whether or
  /// not an error is displayed, either wrap the  [TextFormField] in a fixed
  /// height parent like [SizedBox], or set the [InputDecoration.helperText]
  /// parameter to a space.
  final FormFieldValidator<T>? validator;

  /// Function that returns the widget representing this form field. It is
  /// passed the form field state as input, containing the current value and
  /// validation state of this field.
  final FormFieldBuilder<T> builder;

  /// An optional value to initialize the form field to, or null otherwise.
  final T? initialValue;

  /// Whether the form is able to receive user input.
  ///
  /// Defaults to true. If [autovalidateMode] is not [AutovalidateMode.disabled],
  /// the field will be auto validated. Likewise, if this field is false, the widget
  /// will not be validated regardless of [autovalidateMode].
  final bool enabled;

  /// Used to enable/disable this form field auto validation and update its
  /// error text.
  ///
  /// {@template flutter.widgets.FormField.autovalidateMode}
  /// If [AutovalidateMode.onUserInteraction], this FormField will only
  /// auto-validate after its content changes. If [AutovalidateMode.always], it
  /// will auto-validate even without user interaction. If
  /// [AutovalidateMode.disabled], auto-validation will be disabled.
  ///
  /// Defaults to [AutovalidateMode.disabled], cannot be null.
  /// {@endtemplate}
  final AutovalidateMode autovalidateMode;

  /// Restoration ID to save and restore the state of the form field.
  ///
  /// Setting the restoration ID to a non-null value results in whether or not
  /// the form field validation persists.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  @override
  _FormFieldState<T> createState() => _FormFieldState<T>();
}

/// The current state of a [_FormField]. Passed to the [FormFieldBuilder] method
/// for use in constructing the form field's widget.
class _FormFieldState<T> extends State<_FormField<T>> with RestorationMixin {
  late T? _value = widget.initialValue;
  final RestorableStringN _errorText = RestorableStringN(null);
  final RestorableBool _hasInteractedByUser = RestorableBool(false);

  /// The current value of the form field.
  T? get value => _value;

  /// The current validation error returned by the [_FormField.validator]
  /// callback, or null if no errors have been triggered. This only updates when
  /// [validate] is called.
  String? get errorText => _errorText.value;

  /// True if this field has any validation errors.
  bool get hasError => _errorText.value != null;

  /// True if the current value is valid.
  ///
  /// This will not set [errorText] or [hasError] and it will not update
  /// error display.
  ///
  /// See also:
  ///
  ///  * [validate], which may update [errorText] and [hasError].
  bool get isValid => widget.validator?.call(_value) == null;

  /// Calls the [_FormField]'s onSaved method with the current value.
  void save() {
    widget.onSaved?.call(value);
  }

  /// Resets the field to its initial value.
  void reset() {
    setState(() {
      _value = widget.initialValue;
      _hasInteractedByUser.value = false;
      _errorText.value = null;
    });
    ShakeForm.of(context)?._fieldDidChange();
  }

  /// Calls [_FormField.validator] to set the [errorText]. Returns true if there
  /// were no errors.
  ///
  /// See also:
  ///
  ///  * [isValid], which passively gets the validity without setting
  ///    [errorText] or [hasError].
  bool validate({bool shake = false}) {
    setState(() {
      _validate();
    });
    return !hasError;
  }

  void _validate() {
    if (widget.validator != null) {
      _errorText.value = widget.validator!(_value);
    }
  }

  /// Updates this field's state to the new value. Useful for responding to
  /// child widget changes, e.g. [Slider]'s [Slider.onChanged] argument.
  ///
  /// Triggers the [ShakeForm.onChanged] callback and, if [ShakeForm.autovalidateMode] is
  /// [AutovalidateMode.always] or [AutovalidateMode.onUserInteraction],
  /// revalidates all the fields of the form.
  void didChange(T? value) {
    setState(() {
      _value = value;
      _hasInteractedByUser.value = true;
    });
    ShakeForm.of(context)?._fieldDidChange();
  }

  /// Sets the value associated with this form field.
  ///
  /// This method should only be called by subclasses that need to update
  /// the form field value due to state changes identified during the widget
  /// build phase, when calling `setState` is prohibited. In all other cases,
  /// the value should be set by a call to [didChange], which ensures that
  /// `setState` is called.
  @protected
  // ignore: use_setters_to_change_properties, (API predates enforcing the lint)
  void setValue(T? value) {
    _value = value;
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_errorText, 'error_text');
    registerForRestoration(_hasInteractedByUser, 'has_interacted_by_user');
  }

  @override
  void deactivate() {
    ShakeForm.of(context)?._unregister(this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      switch (widget.autovalidateMode) {
        case AutovalidateMode.always:
          _validate();
          break;
        case AutovalidateMode.onUserInteraction:
          if (_hasInteractedByUser.value) {
            _validate();
          }
          break;
        case AutovalidateMode.disabled:
          break;
      }
    }
    ShakeForm.of(context)?._register(this);
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: Duration(milliseconds: 200),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: WalletTheme.instance.maxWidth,
        ),
        decoration: BoxDecoration(
          color: hasError ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.builder(this),
            if (hasError)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 2,
                ),
                child: Text(
                  errorText!,
                  style: widget.errorStyle ??
                      Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ShakeTextFormField extends _FormField<String> {
  /// Creates a [_FormField] that contains a [TextField].
  ///
  /// When a [controller] is specified, [initialValue] must be null (the
  /// default). If [controller] is null, then a [TextEditingController]
  /// will be constructed automatically and its `text` will be initialized
  /// to [initialValue] or the empty string.
  ///
  /// For documentation about the various parameters, see the [TextField] class
  /// and [TextField.new], the constructor.

  ShakeTextFormField({
    super.key,
    this.controller,
    super.errorStyle,
    this.shakeKey,
    String? initialValue,
    FocusNode? focusNode,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    super.onSaved,
    super.validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    super.restorationId,
    bool enableIMEPersonalizedLearning = true,
    MouseCursor? mouseCursor,
  })  : assert(initialValue == null || controller == null),
        assert(textAlign != null),
        assert(autofocus != null),
        assert(readOnly != null),
        assert(obscuringCharacter != null && obscuringCharacter.length == 1),
        assert(obscureText != null),
        assert(autocorrect != null),
        assert(enableSuggestions != null),
        assert(scrollPadding != null),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(expands != null),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(maxLength == null ||
            maxLength == TextField.noMaxLength ||
            maxLength > 0),
        assert(enableIMEPersonalizedLearning != null),
        super(
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          enabled: enabled ?? decoration?.enabled ?? true,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (_FormFieldState<String> field) {
            final ShakeTextFormFieldState state =
                field as ShakeTextFormFieldState;
            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            void onChangedHandler(String value) {
              field.didChange(value);
              if (onChanged != null) {
                onChanged(value);
              }
            }

            return UnmanagedRestorationScope(
              bucket: field.bucket,
              child: TextField(
                restorationId: restorationId,
                controller: state._effectiveController,
                focusNode: focusNode,
                decoration:
                    effectiveDecoration.copyWith(errorText: field.errorText),
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                style: style,
                strutStyle: strutStyle,
                textAlign: textAlign,
                textAlignVertical: textAlignVertical,
                textDirection: textDirection,
                textCapitalization: textCapitalization,
                autofocus: autofocus,
                toolbarOptions: toolbarOptions,
                readOnly: readOnly,
                showCursor: showCursor,
                obscuringCharacter: obscuringCharacter,
                obscureText: obscureText,
                autocorrect: autocorrect,
                smartDashesType: smartDashesType ??
                    (obscureText
                        ? SmartDashesType.disabled
                        : SmartDashesType.enabled),
                smartQuotesType: smartQuotesType ??
                    (obscureText
                        ? SmartQuotesType.disabled
                        : SmartQuotesType.enabled),
                enableSuggestions: enableSuggestions,
                maxLengthEnforcement: maxLengthEnforcement,
                maxLines: maxLines,
                minLines: minLines,
                expands: expands,
                maxLength: maxLength,
                onChanged: onChangedHandler,
                onTap: onTap,
                onEditingComplete: onEditingComplete,
                onSubmitted: onFieldSubmitted,
                inputFormatters: inputFormatters,
                enabled: enabled ?? decoration?.enabled ?? true,
                cursorWidth: cursorWidth,
                cursorHeight: cursorHeight,
                cursorRadius: cursorRadius,
                cursorColor: cursorColor,
                scrollPadding: scrollPadding,
                scrollPhysics: scrollPhysics,
                keyboardAppearance: keyboardAppearance,
                enableInteractiveSelection:
                    enableInteractiveSelection ?? (!obscureText || !readOnly),
                selectionControls: selectionControls,
                buildCounter: buildCounter,
                autofillHints: autofillHints,
                scrollController: scrollController,
                enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
                mouseCursor: mouseCursor,
              ),
            );
          },
        );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController? controller;
  final GlobalKey<ShakeErrorState>? shakeKey;

  @override
  _FormFieldState<String> createState() => ShakeTextFormFieldState();
}

class ShakeTextFormFieldState extends _FormFieldState<String> {
  RestorableTextEditingController? _controller;
  late final GlobalKey<ShakeErrorState>? _shakeKey;
  final RestorableBool hasInteractedByUser = RestorableBool(false);

  TextEditingController get _effectiveController =>
      _textFormField.controller ?? _controller!.value;

  ShakeTextFormField get _textFormField => super.widget as ShakeTextFormField;
  @override
  void initState() {
    super.initState();
    if (_textFormField.controller == null) {
      _createLocalController(widget.initialValue != null
          ? TextEditingValue(text: widget.initialValue!)
          : null);
    } else {
      _textFormField.controller!.addListener(_handleControllerChanged);
    }
    _shakeKey = _textFormField.shakeKey ?? GlobalKey<ShakeErrorState>();
  }

  @override
  bool validate({bool shake = false}) {
    bool _isValid = super.validate();
    if (!_isValid && shake) {
      _shakeKey?.currentState?.shake();
    }
    return super.validate();
  }

  @override
  Widget build(BuildContext context) {
    return ShakeError(
      key: _shakeKey,
      child: super.build(context),
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    setValue(_effectiveController.text);
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void didUpdateWidget(ShakeTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _textFormField.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && _textFormField.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (_textFormField.controller != null) {
        setValue(_textFormField.controller!.text);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _textFormField.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
  }

  void _handleControllerChanged() {
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }
}
