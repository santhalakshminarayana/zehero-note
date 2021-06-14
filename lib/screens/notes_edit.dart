import 'package:flutter/material.dart';

import 'package:share/share.dart';

import '../models/note.dart';
import '../models/notes_database.dart';
import '../theme/note_colors.dart';

const c1 = 0xFFFDFFFC, c2 = 0xFFFF595E, c3 = 0xFF374B4A, c4 = 0xFF00B1CC, c5 = 0xFFFFD65C, c6 = 0xFFB9CACA,
			c7 = 0x80374B4A;

class NotesEdit extends StatefulWidget {
	final args;

	const NotesEdit(this.args);
	_NotesEdit createState() => _NotesEdit();
}

class _NotesEdit extends State<NotesEdit> {
	String noteTitle = '';
	String noteContent = '';
	String noteColor = 'red';

	TextEditingController _titleTextController = TextEditingController();
	TextEditingController _contentTextController = TextEditingController();

	void onSelectAppBarPopupMenuItem(BuildContext currentContext, String optionName) {
		switch (optionName) {
			case 'Color':
				handlePopupMenuItemColor(currentContext);
				break;
			case 'Sort by A-Z':
				handleNoteSort('ascending');
				break;
			case 'Sort by Z-A':
				handleNoteSort('descending');
				break;
			case 'Share':
				handleNoteShare();
				break;
			case 'Delete':
				handleNoteDelete();
				break;
		}
	}

	void handlePopupMenuItemColor(currentContext) {
		showDialog(
			context: currentContext,
			builder: (context) => ColorPalette(
				parentContext: currentContext,
			),
		).then((colorName) {
			if (colorName != null) {
				setState(() {
					noteColor = colorName;
				});
			}
		});
	}

	void handleNoteSort(String sortOrder) {
		List<String> sortedContentList;
		if (sortOrder == 'ascending') {
			sortedContentList = noteContent.trim().split('\n')..sort();
		}
		else {
			sortedContentList = noteContent.trim().split('\n')..sort((a, b) => b.compareTo(a));
		}
		String sortedContent = sortedContentList.join('\n');
		setState(() {
			noteContent = sortedContent;
		});
		_contentTextController.text = sortedContent;
	}

	void handleNoteShare() async {
		await Share.share(noteContent, subject: noteTitle);
	}

	void handleNoteDelete() async {
		if (widget.args[0] == 'update') {
			try {
				NotesDatabase notesDb = NotesDatabase();
		  	await notesDb.initDatabase();
			  int result = await notesDb.deleteNote(widget.args[1]['id']);
			  await notesDb.closeDatabase();
			} catch (e) {

			} finally {
				Navigator.pop(context);
				return;
			}
		}
		else {
			Navigator.pop(context);
			return;
		}
	}

	void handleTitleTextChange() {
		setState(() {
			noteTitle = _titleTextController.text.trim();
		});
	}

	void handleNoteTextChange() {
		setState(() {
			noteContent = _contentTextController.text.trim();
		});
	}

	Future<void> _insertNote(Note note) async {
	  NotesDatabase notesDb = NotesDatabase();
	  await notesDb.initDatabase();
	  int result = await notesDb.insertNote(note);
	  await notesDb.closeDatabase();
	}

	Future<void> _updateNote(Note note) async {
	  NotesDatabase notesDb = NotesDatabase();
	  await notesDb.initDatabase();
	  int result = await notesDb.updateNote(note);
	  await notesDb.closeDatabase();
	}

	void handleBackButton() async {
		if (noteTitle.length == 0) {
			// Go Back without saving
			if (noteContent.length == 0) {
				Navigator.pop(context);
				return;
			}
			else {
				String title = noteContent.split('\n')[0];
				if (title.length > 31) {
					title = title.substring(0, 31);
				}
				setState(() {
					noteTitle = title;
				});
				//_titleTextController.text = title;
			}
		}
		// Save New note
		if (widget.args[0] == 'new') {
			Note noteObj = Note(
				title: noteTitle, 
				content: noteContent, 
				noteColor: noteColor
			);
			try {
				await _insertNote(noteObj);
			} catch (e) {

			} finally {
				Navigator.pop(context);
				return;
			}
		}
		// Update Note
		else if (widget.args[0] == 'update') {
			Note noteObj = Note(
				id: widget.args[1]['id'],
				title: noteTitle, 
				content: noteContent, 
				noteColor: noteColor
			);
			try {
				await _updateNote(noteObj);
			} catch (e) {

			} finally {
				Navigator.pop(context);
				return;
			}
		}
	}

	@override
	void initState() {
		super.initState();
		noteTitle = (widget.args[0] == 'new'? '': widget.args[1]['title']);
		noteContent = (widget.args[0] == 'new'? '': widget.args[1]['content']);
		noteColor = (widget.args[0] == 'new'? 'red': widget.args[1]['noteColor']);

		_titleTextController.text = (widget.args[0] == 'new'? '': widget.args[1]['title']);
		_contentTextController.text = (widget.args[0] == 'new'? '': widget.args[1]['content']);
		_titleTextController.addListener(handleTitleTextChange);
		_contentTextController.addListener(handleNoteTextChange);
	}

	@override
	void dispose() {
		_titleTextController.dispose();
		_contentTextController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: () async {
				handleBackButton();
				true;
			},
			child: Scaffold(
				backgroundColor: Color(NoteColors[this.noteColor]['l']),
				appBar: AppBar(
					backgroundColor: Color(NoteColors[this.noteColor]['b']),

					leading: IconButton(
						icon: const Icon(
							Icons.arrow_back,
							color: const Color(c1),
						),
						tooltip: 'Back',
						onPressed: () => handleBackButton(),
					),

					title: NoteTitleEntry(_titleTextController),

					// sctions
					actions: [
						appBarPopMenu(
							parentContext: context,
							onSelectPopupmenuItem: onSelectAppBarPopupMenuItem,
						),
					],
				),

				body: NoteEntry(_contentTextController),
			),
		);
	}
}

class NoteTitleEntry extends StatefulWidget {
	final _textFieldController;

	NoteTitleEntry(this._textFieldController);

	@override
	_NoteTitleEntry createState() => _NoteTitleEntry();
}

class _NoteTitleEntry extends State<NoteTitleEntry> with WidgetsBindingObserver {
	FocusNode _textFieldFocusNode = FocusNode();

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addObserver(this);
	}

	@override
	void didChangeMetrics() {
		final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
		if (bottomInset <= 0.0) {
			_textFieldFocusNode.unfocus();
		}
	}

	@override
	void dispose() {
		_textFieldFocusNode.dispose();
		WidgetsBinding.instance.removeObserver(this);
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return TextField(
			controller: widget._textFieldController,
			focusNode: _textFieldFocusNode,
			decoration: InputDecoration(
				border: InputBorder.none,
				focusedBorder: InputBorder.none,
				enabledBorder: InputBorder.none,
				errorBorder: InputBorder.none,
				disabledBorder: InputBorder.none,
				contentPadding: EdgeInsets.all(0),
				counter: null,
				counterText: "",
				hintText: 'Title',
				hintStyle: TextStyle(
					fontSize: 21,
					fontWeight: FontWeight.bold,
					height: 1.5,
				),
			),
			maxLength: 31,
			maxLines: 1,
			style: TextStyle(
				fontSize: 21,
				fontWeight: FontWeight.bold,
				height: 1.5,
				color: Color(c1),
			),
			textCapitalization: TextCapitalization.words,
		);
	}
}

class NoteEntry extends StatefulWidget {
	final _textFieldController;

	NoteEntry(this._textFieldController);

	@override
	_NoteEntry createState() => _NoteEntry();
}

class _NoteEntry extends State<NoteEntry> with WidgetsBindingObserver {
	FocusNode _textFieldFocusNode = FocusNode();

	@override
	void initState() {
		super.initState();
		WidgetsBinding.instance.addObserver(this);
	}

	@override
	void didChangeMetrics() {
		final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
		if (bottomInset <= 0.0) {
			_textFieldFocusNode.unfocus();
		}
	}

	@override
	void dispose() {
		_textFieldFocusNode.dispose();
		WidgetsBinding.instance.removeObserver(this);
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Container(
			height: MediaQuery.of(context).size.height,
			padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			child: TextField(
				controller: widget._textFieldController,
				focusNode: _textFieldFocusNode,
				maxLines: null,
				textCapitalization: TextCapitalization.sentences,
				decoration: null,
				style: TextStyle(
					fontSize: 19,
					height: 1.5,
				),
			),
		);
	}
}

// A PopUp Widget shows different colors
class ColorPalette extends StatelessWidget {
	final parentContext;

	const ColorPalette({ 
		@required this.parentContext,
	});

	@override
	Widget build(BuildContext context) {
		return Dialog(
			backgroundColor: Color(c1),
			clipBehavior: Clip.hardEdge,
			insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(2),
			),
			child: Container(
				padding: EdgeInsets.all(8),
				child: Wrap(
					alignment: WrapAlignment.start,
					spacing: MediaQuery.of(context).size.width * 0.02,
					runSpacing: MediaQuery.of(context).size.width * 0.02,
					children: NoteColors.entries.map((entry) {
						return GestureDetector(
							onTap: () => Navigator.of(context).pop(entry.key),
							child: Container(
								width: MediaQuery.of(context).size.width * 0.12,
								height: MediaQuery.of(context).size.width * 0.12,
								decoration: BoxDecoration(
									borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.06),
									color: Color(entry.value['b']),
								),
							),
						);
					}).toList(),
				),
			),
		);
	}
}

// More Menu to display various options like Color, Sort, Share...
class appBarPopMenu extends StatelessWidget {
	final popupMenuButtonItems = const {
		1: const {'name': 'Color', 'icon': Icons.color_lens},
		2: const {'name': 'Sort by A-Z', 'icon': Icons.sort_by_alpha},
		3: const {'name': 'Sort by Z-A', 'icon': Icons.sort_by_alpha},
		4: const {'name': 'Share', 'icon': Icons.share},
		5: const {'name': 'Delete', 'icon': Icons.delete},
	};
	final parentContext;
	final void Function(BuildContext, String) onSelectPopupmenuItem;

	appBarPopMenu({ 
		@required this.parentContext,
		@required this.onSelectPopupmenuItem,
	});

	@override
	Widget build(BuildContext context) {
		return PopupMenuButton(
			icon: const Icon(
				Icons.more_vert,
				color: const Color(c1),
			),
			color: Color(c1),
	    itemBuilder: (context) {
	    	var list = popupMenuButtonItems.entries.map((entry) {
	    		return PopupMenuItem(
			      child: Container(
			      	constraints: BoxConstraints(
			      		minWidth: MediaQuery.of(context).size.width * 0.3,
			      	),
			      	child: Row(
				      	children: [
				      		Padding(
				      			padding: EdgeInsets.only(right: 8),
				      			child: Icon(
				        			entry.value['icon'],
				        			color: const Color(c3),
				        		),
				      		),
				      		Text(
				        		entry.value['name'],
				        		style: TextStyle(
				        			color: Color(c3),
				        		),
				        	),
				        ],
			      	),
			      ),
			      value: entry.key,
	    		);
	    	}).toList();
	    	return list;
	    },
	    onSelected: (value) {
	    	onSelectPopupmenuItem(parentContext, popupMenuButtonItems[value]['name']);
	    },
	  );
	}
}