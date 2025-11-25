#Requires AutoHotkey >=2.1-alpha.3

class StepResult {
  /**
   * @param ok Whether the postcondition was met.
   * @param data Data to be passed to the following Function.
   */
  __New(ok, data) {
    this.ok := ok
    this.data := data
  }
}

class Step {
  /**
   * @param precondition Function definition expression *returning a `StepResult`* that checks for a **preceding** condition (e. g. A notification color above a button leading to a specific screen).
   * @param action Function definition expression with an action to be performed each time the precondition is met (e. g. Pressing a key), optionally accepting a `StepResult`.
   * @param postcondition Function definition expression *returning a `StepResult`* that checks for a **desired** condition (e. g. A color that identifies the aforementioned screen).
   * 
   * @see [Function Definition Expressions](https://www.autohotkey.com/docs/alpha/Functions.htm#funcexpr)
   */
  __New(precondition, action, postcondition) {
    this.precondition := precondition
    this.action := action
    this.postcondition := postcondition
  }

  /**
   * Performs the given action each time the precondition is met and until the postcondition is met.
   * The precondition must be false before evaluating the postcondition. If none are met, the method is simply polled again.
   * 
   * @param timeout Alloted time for the postcondition to be met (in milliseconds).
   * @param poll Wait time before each polling (in milliseconds).
   * @returns Whether the postcondition was met before reaching the limit outlined in the `timeout` parameter.
   */
  perform(timeout, poll, pollVariance) {
    maxPoll := poll + pollVariance
    deadline := A_TickCount + timeout
    while (A_TickCount < deadline) {
      preconditionData := this.precondition.Call()
      if (preconditionData.ok) {
        this.action.Call()
      } else {
        postconditionData := this.postcondition.Call()
        if (postconditionData.ok) {
          return true
        }
      }
      Sleep(Random(poll, maxPoll))
    }
    return false
  }

  performWithParams(timeout, poll, pollVariance, preconditionParams*) {
    maxPoll := poll + pollVariance
    deadline := A_TickCount + timeout
    while (A_TickCount < deadline) {
      preconditionData := this.precondition.Call(preconditionParams)
      if (preconditionData.ok) {
        this.action.Call(preconditionData.data)
      } else {
        postconditionData := this.postcondition.Call()
        if (postconditionData.ok) {
          return true
        }
      }
      Sleep(Random(poll, maxPoll))
    }
    return false
  }
}

/**
 * Checks against a condition and applies a slight delay before returning the result in the event it is met. It may be optionally rechecked before returning the result.
 *
 * This is useful to account for conditions that are supposed to be met at the same stage, but with the latter having a slight delay
 * (e. g. Having accessed a menu and immediately checking if there are notifications may fail to find existing ones if they take even a millisecond to load after the menu is detected).
 * 
 * For good measure, it should be used on any steps that access a menu.
 *
 * @param detectFunction Function definition expression that evaluates a condition (e. g. App is currently at X menu, rewards have been claimed, etc) into a `boolean`-type value.
 * @param wait Time to wait after the condition is met (in milliseconds).
 * @param recheck Whether to reevaluate a previously met condition before returning the result, waiting again if true. Defaults to `false`.
 * 
 * This may protect against instances where, for example, an underlying menu is displayed for a slight moment before drawing the actual, pop-up style menu.
 *
 * @example checkDelayed(() {
 *  PixelGetColor(100, 100) == '0x222222' ; is main menu
 * }, 500, false) ; notifications can be checked for after this if it returns `true`
 */
checkDelayed(detectFunction, wait, recheck := false) {
  result := detectFunction.Call()
  if (result) {
    Sleep(wait)
    if (recheck) {
      result := detectFunction.Call()
      if (result) {
        Sleep(wait)
      }
    }
  }
  return result
}
