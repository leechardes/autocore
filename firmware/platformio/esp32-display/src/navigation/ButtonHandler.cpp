/**
 * @file ButtonHandler.cpp
 * @brief Implementation of button handler
 */

#include "navigation/ButtonHandler.h"
#include "core/Logger.h"

extern Logger* logger;

ButtonHandler::ButtonHandler(uint8_t prevPin, uint8_t selectPin, uint8_t nextPin)
    : pinPrev(prevPin), pinSelect(selectPin), pinNext(nextPin),
      prevState(true), selectState(true), nextState(true),
      prevDebounce(0), selectDebounce(0), nextDebounce(0),
      prevPressTime(0), selectPressTime(0), nextPressTime(0),
      prevLongPressed(false), selectLongPressed(false), nextLongPressed(false) {
    
    // Configure pins as input with pullup
    pinMode(pinPrev, INPUT_PULLUP);
    pinMode(pinSelect, INPUT_PULLUP);
    pinMode(pinNext, INPUT_PULLUP);
    
    logger->info("ButtonHandler initialized - Prev:" + String(pinPrev) + 
                " Select:" + String(pinSelect) + " Next:" + String(pinNext));
}

void ButtonHandler::update() {
    handleButton(pinPrev, prevState, prevDebounce, prevPressTime, prevLongPressed,
                onPrevCallback, onLongPrevCallback, "Previous");
    
    handleButton(pinSelect, selectState, selectDebounce, selectPressTime, selectLongPressed,
                onSelectCallback, onLongSelectCallback, "Select");
    
    handleButton(pinNext, nextState, nextDebounce, nextPressTime, nextLongPressed,
                onNextCallback, onLongNextCallback, "Next");
}

bool ButtonHandler::readButton(uint8_t pin) {
    return digitalRead(pin);
}

void ButtonHandler::handleButton(uint8_t pin, bool& state, unsigned long& debounce,
                               unsigned long& pressTime, bool& longPressed,
                               ButtonCallback shortCallback, ButtonCallback longCallback,
                               const String& buttonName) {
    
    bool reading = readButton(pin);
    
    // Check if button state changed
    if (reading != state) {
        debounce = millis();
    }
    
    // Check if debounce time has passed
    if ((millis() - debounce) > DEBOUNCE_DELAY) {
        bool oldState = state;
        state = reading;
        
        // Button just pressed (active low)
        if (!state && oldState) {
            pressTime = millis();
            longPressed = false;
            logger->debug(buttonName + " button pressed");
        }
        
        // Button just released
        else if (state && !oldState) {
            unsigned long pressDuration = millis() - pressTime;
            
            // Only trigger short press if long press wasn't triggered
            if (!longPressed && shortCallback && pressDuration < LONG_PRESS_TIME) {
                logger->debug(buttonName + " button short press");
                shortCallback();
            }
            
            pressTime = 0;
            longPressed = false;
        }
        
        // Button held down
        else if (!state && pressTime > 0) {
            unsigned long pressDuration = millis() - pressTime;
            
            // Check for long press
            if (!longPressed && pressDuration >= LONG_PRESS_TIME) {
                if (longCallback) {
                    logger->debug(buttonName + " button long press");
                    longCallback();
                }
                longPressed = true;
            }
        }
    }
}

uint32_t ButtonHandler::getPressedButton() {
    // For LVGL keypad navigation
    if (isPrevPressed()) return 1;  // Previous button
    if (isSelectPressed()) return 2; // Select button  
    if (isNextPressed()) return 3;   // Next button
    
    return 0;
}