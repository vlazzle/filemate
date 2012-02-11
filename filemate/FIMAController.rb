#
#  controller.rb
#  filemate
#
#  Created by Vladimir Chernis on 2/9/12.
#  Copyright 2012 __MyCompanyName__. All rights reserved.
#


# protocols:
# - NSTableViewDataSource
# - NSTableViewDataDelegate
# - NSControlDelegate

class FIMAController
    
    MAX_NUM_FILES = 100
    
    attr_writer :filelist_tableview
    attr_accessor :filename_textfield
    
    def awakeFromNib
        @base_path = Pathname.new('/Users/vlad/code/filemate/test_dir')
        @files = []
        
        @window = NSApplication.sharedApplication.delegate.window
        
        NSNotificationCenter.defaultCenter.addObserver self, selector:'windowDidBecomeKey:', name:NSWindowDidBecomeKeyNotification, object:@window
        
        reset_filelist
    end
    
    # - (void)windowDidBecomeKey:(NSNotification *)notification
    def windowDidBecomeKey(notification)
        @window.makeFirstResponder @filename_textfield
    end
    
    # - (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
    def numberOfRowsInTableView(tableView)
        @files.length
    end
    
    # - (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
    def tableView(aTableView, objectValueForTableColumn:aTableColumn, row:rowIndex)
        @files[rowIndex]
    end
    
    # - (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
    def tableView(aTableView, shouldEditTableColumn:aTableColumn, row:rowIndex)
        open_path = (@base_path + @files[rowIndex]).to_s
        puts "open_path: #{open_path}"
        NSWorkspace.sharedWorkspace.openFile open_path
        
        false
    end

    # - (void)controlTextDidChange:(NSNotification *)aNotification
    def controlTextDidChange(aNotification)
        sender = aNotification.object
        path_exression = sender.stringValue.dup
        update_filelist(path_exression)
    end
    
    # - (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
    def control(control, textView:fieldEditor, doCommandBySelector:commandSelector)
        puts "commandSelector: #{commandSelector}"
        selector_str = commandSelector.to_s
        
        if %w(insertNewline: moveDown: moveUp:).include?(selector_str)
            unless @files.empty?
                @window.makeFirstResponder @filelist_tableview
                row_index = 'moveUp:' == selector_str ? @files.length - 1 : 0
                row = NSIndexSet.indexSetWithIndex row_index
                @filelist_tableview.selectRowIndexes row, byExtendingSelection:false
            end
            
            return true
        end
        
        false
    end
    
    protected
    
    def reset_filelist
        update_filelist ''
    end
    
    def update_filelist(path_exression)        
        path_exression << '*' unless path_exression.include? '*'
        path_exression = "**/#{path_exression}"
        
        glob = (@base_path + path_exression).to_s
        puts "glob: #{glob}"
        files = Pathname.glob(glob).slice(0, MAX_NUM_FILES)
        files.select! &:file?
        files.map! {|f| f.relative_path_from(@base_path) }
        @files = files
        puts "matches: #{@files}"
        
        @filelist_tableview.reloadData
    end
end