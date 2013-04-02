(*
	SUPPORT.SCPT
	Developed by Chris Sauve of [pxldot](http://pxldot.com).

	# DESCRIPTION
	
	Quick access to a support folder for the project by putting your choice of "@support", "@folder" or "@reference" before the support
	folder path in the project note. The script will automatically detect this and open the support folder in Finder (or PathFinder, if
	installed). If no support folder exists, the script will ask you to select it and will remember your selection.
	
	
	# LICENSE
	
	Use it, change it, enjoy it. Please don't blatently pass off my work as your own. Be cool.
	
	
	# INSTALLATION
	
	-	Copy this script to ~/Library/Scripts/Applications/Omnifocus (you may have to use the
		Go > Go to Folder… menu in your file navigation application of choice as the user library
		folder is hidden on Mac OS X 10.7+. After you select this menu item, type the path above and
		hit enter).
	-	If you prefer, you can have this script be activated by a utility like Keyboard Maestro or FastScripts
	
	
	# VERSION INFORMATION
		
		0.1 (April 2, 2013): Initial release
*)property folderDelim : "@support"property firstRun : trueproperty defaultToFirstProject : trueproperty debug : trueif firstRun and not debug then	try		set folderDelim to item 1 of (choose from list {"@support", "@reference", "@folder"} with prompt "Which syntax would you like to denote reference folders in the project notes?")		set firstRun to false	on error		return	end tryend iftell application "OmniFocus"	tell front document window of default document		try			set theSelection to value of selected trees of content			if length of theSelection is 0 then set theSelection to value of selected trees of sidebar			if ((count of theSelection) is 0) then				display alert "Please select at least one project or task."				return			end if			set theProjects to {}			repeat with theItem in theSelection				if (class of theSelection is project) and (not my inList(theItem, theProjects)) then					set the end of theProjects to theItem				else if not my inList(containing project of theItem, theProjects) then					set the end of theProjects to (containing project of theItem)				end if			end repeat		on error			display alert "Please select at least one project or task."			return		end try				if (length of theProjects > 1) and (not defaultToFirstProject) then			set projectNames to my getNames(theProjects)			set selectedProjectNames to (choose from list projectNames with prompt "Which project(s) would you like to open/ create a project folder for?" with multiple selections allowed)			if selectedProjectNames is false then return			if length of selectedProjectNames is 0 then				display alert "You didn't select any of the folders."				return			end if			set selectedProjects to my assessList(selectedProjectNames, projectNames, theProjects)		else			set selectedProjects to item 1 of theProjects		end if				set thePaths to {}		repeat with theProject in selectedProjects			if (note of theProject contains folderDelim) then				set the end of thePaths to my identifyFolder(note of theProject)			else				try					set chosenFolder to (choose folder with prompt "Select the folder that contains the reference material for the project " & quote & (name of theProject) & quote & ".") as string				on error					return				end try				if the note of theProject is "" then					set the note of theProject to (folderDelim & " " & chosenFolder)				else					set the note of theProject to (the note of theProject & return & folderDelim & " " & chosenFolder)				end if				set the end of thePaths to chosenFolder			end if		end repeat				if application id "com.cocoatech.PathFinder" is running then			tell application id "com.cocoatech.PathFinder"				activate				open thePaths			end tell		else			tell application id "com.apple.finder"				repeat with aFolder in thePaths					open folder aFolder				end repeat				activate			end tell		end if			end tellend tellon inList(theItem, theList)	if length of theList is 0 then return false	repeat with anItem in theList		if id of anItem is id of theItem then return true	end repeat	return falseend inListon getNames(theList)	tell application "OmniFocus"		tell default document			set theReturn to {}			repeat with theItem in theList				set the end of theReturn to name of theItem			end repeat			return theReturn		end tell	end tellend getNameson assessList(theSelection, theList, theOriginals)	set theReturn to {}	repeat with j from 1 to (length of theSelection)		repeat with i from 1 to (length of theList)			if (item j of theSelection) is (item i of theList) then				set the end of theReturn to item i of theOriginals				exit repeat			end if		end repeat	end repeat	return theReturnend assessListon identifyFolder(theNote)	set paras to every paragraph of theNote	repeat with para in paras		if para starts with folderDelim then			set theText to para			exit repeat		end if	end repeat	set text item delimiters to {folderDelim & " ", folderDelim}	set theText to every text item of theText	set text item delimiters to ""	set theText to theText as textend identifyFolderon changePath(thePath)	set text item delimiters to "/"	set thePath to every text item of thePath	set text item delimiters to ":"	return (thePath as text)end changePath