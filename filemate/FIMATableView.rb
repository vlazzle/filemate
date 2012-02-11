#
#  FIMATableView.rb
#  filemate
#
#  Created by Vladimir Chernis on 2/10/12.
#  Copyright 2012 __MyCompanyName__. All rights reserved.
#


class FIMATableView < NSTableView
    DOWN_ARROW_KEY_CODE = 125
    UP_ARROW_KEY_CODE = 126
    
    # - (void)keyUp:(NSEvent *)theEvent
    def keyDown(theEvent)
        going_up = UP_ARROW_KEY_CODE == theEvent.keyCode
        going_down = DOWN_ARROW_KEY_CODE == theEvent.keyCode
        if !theEvent.isARepeat && ((self.first_row_selected? && going_up) || (self.last_row_selected? && going_down))
            window = NSApplication.sharedApplication.delegate.window
            window.makeFirstResponder self.delegate.filename_textfield
        else
            super
        end
    end
    
    def first_row_selected?
        0 == self.selectedRow
    end
    
    def last_row_selected?
        self.numberOfRows == 1 + self.selectedRow
    end
end