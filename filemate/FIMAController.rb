#
#  controller.rb
#  filemate
#
#  Created by Vladimir Chernis on 2/9/12.
#  Copyright 2012 __MyCompanyName__. All rights reserved.
#

class FIMAController
    
    MAX_NUM_FILES = 100
    
    attr_writer :filelist_tableview
    attr_accessor :filename_textfield
    attr_writer :path_control
    attr_writer :fileicon_imageview
    
    # NSNibAwaking
    # - (void)awakeFromNib
    def awakeFromNib
        @base_path = Pathname.new('/Users/vlad/code/filemate/test_dir')
        @files = []
        
        @window = NSApplication.sharedApplication.delegate.window
        
        NSNotificationCenter.defaultCenter.addObserver self, selector:'windowDidBecomeKey:', name:NSWindowDidBecomeKeyNotification, object:@window
        
        reset_filelist
        
        @path_control.setURL(NSURL.URLWithString(@base_path.to_s))
    end
    
    # NSWindowDelegate
    # - (void)windowDidBecomeKey:(NSNotification *)notification
    def windowDidBecomeKey(notification)
        @window.makeFirstResponder @filename_textfield
    end
    
    # NSTableViewDataSource
    # - (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
    def numberOfRowsInTableView(tableView)
        @files.length
    end
    
    # NSTableViewDataSource
    # - (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
    def tableView(aTableView, objectValueForTableColumn:aTableColumn, row:rowIndex)
        @files[rowIndex]
    end
    
    # NSTableViewDelegate
    # - (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
    def tableView(aTableView, shouldEditTableColumn:aTableColumn, row:rowIndex)
        NSWorkspace.sharedWorkspace.openFile(self.file_path_for_row(rowIndex))
        
        false
    end
    
    # NSTableViewDelegate
    # - (void)tableViewSelectionDidChange:(NSNotification *)aNotification
    def tableViewSelectionDidChange(aNotification)
        selected_path = self.file_path_for_row(@filelist_tableview.selectedRow)
        @path_control.setURL(NSURL.URLWithString(selected_path))
        
        img = NSWorkspace.sharedWorkspace.iconForFile selected_path
        @fileicon_imageview.setImage img
    end
    
    # NSControl delegate method
    # - (void)controlTextDidChange:(NSNotification *)aNotification
    def controlTextDidChange(aNotification)
        sender = aNotification.object
        path_exp = sender.stringValue.dup
        update_filelist(path_exp)
    end
    
    # NSControlTextEditingDelegate
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
    
    def update_filelist(path_exp)
        self.clear_file_selection
        
        path_exp << '*' unless path_exp.include? '*'
        path_exp = "**/#{path_exp}"
        
        glob = (@base_path + path_exp).to_s
        puts "glob: #{glob}"
        files = Pathname.glob(glob).slice(0, MAX_NUM_FILES)
        files.select! &:file?
        files.map! {|f| f.relative_path_from(@base_path) }
        @files = files
        puts "matches: #{@files}"
        
        @filelist_tableview.reloadData
    end
    
    def file_path_for_row(row_index)
        file = @files[row_index]
        puts "file #{row_index} #=> #{file}"
        (@base_path + file).to_s
    end
    
    def clear_file_selection
        # deselect any rows to prevent tableViewSelectionDidChange from firing
        # when there are no matching files to select from
        @filelist_tableview.deselectAll self
        
        @fileicon_imageview.setImage nil
    end
end