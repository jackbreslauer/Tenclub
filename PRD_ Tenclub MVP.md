PRD: Tenclub MVP

* Objective:  
  * Define requirements for building an MVP of a screen time management iOS app called ‘TenClub’  
* Background:   
  * This app is designed to represent an opinionated philosophy about how best to manage screentime. Namely, the core contention is that the number of screen unlocks is the critical variable to manage, as these are indicative of the disruption and distraction from the rest of life; time on device, time on specific apps and notification volume are less important  
  * This is intended to be an MVP and will need to scale to supporting more customization over time, we should look to build using scalable infrastructure and coding practices where possible without overbuilding  
  * Please raise any important architectural or technical decisions to me as we build (for example, which features to implement on app or server side, etc)  
  * I’ve divided the initial releases into V1-V4. Lets build sequentially to make sure we are happy at each point   
* User Stories:  
  * As a tenclub user:  
    * V1 When opening the app I want to see a count of the number of screen unlocks that day, so I can manage towards the limit of ten  
    * V3 I want to be able to input the name and the phone number of an accountability partner, so that I can be held accountable when I exceed ten unlocks per day  
    * V2 can see the number of unlocks for the day on a home screen widget, so I can easily understand how I am tracking without opening the tenclub app   
  *  V3 As a tenclub accountability partner:  
    * I wish to notified that a tenclub user would like me to be an accountability partner, and given an explicit opt-in, so that my role is clear and consensual  
    * I wish to receive a succinct text message each time my tenclub accountability buddy (the user) exceeds ten unlocks per day, so that I can hold them accountable in whichever way seems right to me   
* Visual Theme:
  * The app is themed around a deck of playing cards, with "Tenclub" representing the 10 of Clubs
  * App icon: 10 of Clubs playing card
  * Unlock count is displayed as a playing card:
    * 1 unlock = Ace of Clubs
    * 2-10 unlocks = Corresponding number card of Clubs
    * 11+ unlocks = Joker card (with "BUSTED!" message)
  * The numeric count is also displayed below the card
  * Home screen widget (V2) will mirror this card display

* Functional Requirements:
  * Core user experience:
    *  V2 Widget:
      * Simple iOS homescreen widget displaying the appropriate playing card based on unlock count
    * App UI
      * V1 Simple tab structure:
        * Home:
          * Display unlock count as a playing card (Ace through 10 of Clubs, or Joker if >10)
          * Show numeric count below the card
          * If number is \>10, display a message saying "No tenclub today\! Better luck tomorrow  
          * Unlock data should be   
          * Note: use the iOS screentime API to obtain unlocks data, and request any permissions from the end user as needed  
        * V3 Settings  
          * For now, this will only include the optional designation of an accountability buddy  
          * If no buddy has been designated, show text saying “Enter phone number of accountability buddy” (optional)  
          * If phone number is entered, show phone number of accountability buddy, with option to delete (“X”)  
          * If deleted, allow the entry of a new accountability buddy phone number  
          * Phone number entry field should only accept standard US numbers (XXX-XXX-XXXX)  
          * V3 (don’t build for now)  
            * Show user validation of whether accountability buddy has accepted the invitation  
    * V3 Accountability buddy experience:  
      * Note: I have a technical blind spot here and don’t exactly know how to set up the SMS piece- please surface important considerations and decisions as you see fit  
      * When a user  
      * When a given user has input a valid US phone number for an accountability buddy, send that person a text message (not important what number the message is from), with the following text:  
        * “Hi there, your friend has requested that you help them manage their screentime by acting as their Tenclub accountability buddy. You will receive a text each time they fail to stay within the limit of ten unlocks per day. To accept this request, respond with “YES”, otherwise ignore and you will not be texted. You can text “STOP” at any time to no longer receive messages”  
        * If the buddy inputs “YES”, then, each time the designated user exceeds 10 phone unlocks in a day, send them a message with the following copy:  
          * “This is the Tenclub accountabilitybot- yourhkh friend has exceeded their limit for today- don’t be too hard on them\! (Text STOP to unsubscribe)  
  * V4 (do not build for now)  
    * User account registration and management system  
    * Centralized storage of user unlock data per day
