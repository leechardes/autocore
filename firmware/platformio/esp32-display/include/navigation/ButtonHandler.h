/**
 * @file ButtonHandler.h
 * @brief Handler para os três botões de navegação
 */

#ifndef BUTTON_HANDLER_H
#define BUTTON_HANDLER_H

#include <Arduino.h>
#include <functional>

typedef std::function<void()> ButtonCallback;

class ButtonHandler {
private:
    // Pin definitions
    uint8_t pinPrev;
    uint8_t pinSelect;
    uint8_t pinNext;
    
    // Button states
    bool prevState;
    bool selectState;
    bool nextState;
    
    // Debounce
    unsigned long prevDebounce;
    unsigned long selectDebounce;
    unsigned long nextDebounce;
    static const unsigned long DEBOUNCE_DELAY = 50;
    
    // Long press detection
    unsigned long prevPressTime;
    unsigned long selectPressTime;
    unsigned long nextPressTime;
    static const unsigned long LONG_PRESS_TIME = 1000;
    
    // Callbacks
    ButtonCallback onPrevCallback;
    ButtonCallback onSelectCallback;
    ButtonCallback onNextCallback;
    ButtonCallback onLongPrevCallback;
    ButtonCallback onLongSelectCallback;
    ButtonCallback onLongNextCallback;
    
    // Flags
    bool prevLongPressed;
    bool selectLongPressed;
    bool nextLongPressed;
    
public:
    ButtonHandler(uint8_t prevPin, uint8_t selectPin, uint8_t nextPin);
    
    // Update button states (call in loop)
    void update();
    
    // Set callbacks
    void onPrevious(ButtonCallback callback) { onPrevCallback = callback; }
    void onSelect(ButtonCallback callback) { onSelectCallback = callback; }
    void onNext(ButtonCallback callback) { onNextCallback = callback; }
    
    void onLongPrevious(ButtonCallback callback) { onLongPrevCallback = callback; }
    void onLongSelect(ButtonCallback callback) { onLongSelectCallback = callback; }
    void onLongNext(ButtonCallback callback) { onLongNextCallback = callback; }
    
    // Get current button states
    bool isPrevPressed() const { return !prevState; }
    bool isSelectPressed() const { return !selectState; }
    bool isNextPressed() const { return !nextState; }
    
    // For LVGL integration
    uint32_t getPressedButton();
    
private:
    bool readButton(uint8_t pin);
    void handleButton(uint8_t pin, bool& state, unsigned long& debounce, 
                     unsigned long& pressTime, bool& longPressed,
                     ButtonCallback shortCallback, ButtonCallback longCallback,
                     const String& buttonName);
};

#endif // BUTTON_HANDLER_H