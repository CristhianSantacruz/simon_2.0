import 'package:flutter/material.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/comment_model.dart';
import 'package:simon_final/models/comment_model_dto_request.dart';
import 'package:simon_final/providers/comments_bydocument_provider.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ShowCommentsModal {
  static void showCommentsModal(BuildContext context, int documentId) {
    showModalBottomSheet(
      backgroundColor: simon_finalSecondaryColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          snap: true,
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return _CommentsModalContent(
              //comments: comments,
              scrollController: scrollController,
              documentId: documentId,
            );
          },
        );
      },
    );
  }
}

class _CommentsModalContent extends StatefulWidget {
  //final List<CommentModel> comments;
  final ScrollController scrollController;
  final int documentId;

  const _CommentsModalContent({
    //required this.comments,
    required this.scrollController,
    required this.documentId,
  });

  @override
  _CommentsModalContentState createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<_CommentsModalContent> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Set<int> _expandedComments = {};
  //List<CommentModel> commentsByDocumentId = [];
  int? _parentId;

  @override
  void initState() {
    super.initState();
    Provider.of<DocumentCommentProvider>(context, listen: false)
        .getCommentsByDocumentId(widget.documentId);
  }

  void _replyToComment(int parentId) {
    setState(() {
      _parentId = parentId; // Establecer el ID del comentario padre
      _focusNode.requestFocus(); // Enfocar el campo de texto
    });
  }

  void _createComment(CommentModelDtoRequest commentPost, int documentId) {
    if (_commentController.text.isNotEmpty) {
      // Si hay un parentId, agregarlo al comentario
      if (_parentId != null) {
        commentPost.parent_id = _parentId;
      }

      // Crear el comentario
      Provider.of<DocumentCommentProvider>(context, listen: false).createComment(commentPost, documentId);

      setState(() {
        Provider.of<DocumentCommentProvider>(context, listen: false)
            .getCommentsByDocumentId(widget.documentId);
      });

      // Limpiar el campo de texto y restablecer el parentId
      _commentController.clear();
      _focusNode.unfocus();
      setState(() {
        _parentId = null; // Restablecer el parentId
      });
    }
  }

  void _deleteCommentById(int commentId, int documentId,int userId) async {
    Provider.of<DocumentCommentProvider>(context, listen: false)
        .removeDocumentComment(commentId, documentId,userId);
    toast("Comentario eliminado",
        gravity: ToastGravity.TOP,
        bgColor: simon_finalPrimaryColor,
        textColor: white_color);
    Navigator.pop(context);
  }

  void _updateComment(int commentId, String newMessage, int documentId,int userId,int profileId) {
    Provider.of<DocumentCommentProvider>(context, listen: false)
        .updateDocumentComment(commentId, newMessage, documentId,userId,profileId);

    setState(() {
      Provider.of<DocumentCommentProvider>(context, listen: false);
    });
    Navigator.pop(context);
  }

  void _toggleReplies(int index) {
    setState(() {
      if (_expandedComments.contains(index)) {
        _expandedComments.remove(index); // Contraer
      } else {
        _expandedComments.add(index); // Expandir
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? 
           const Color.fromARGB(255, 104, 107, 114) : simonGris,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          children: [
            _buildDragHandle(),
            _buildTitle(),
            Consumer<DocumentCommentProvider>(
              builder: (context, commentProvider, child) {
                if (commentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (commentProvider.error) {
                  return const Center(
                    child: Text(
                        textAlign: TextAlign.center,
                        "Hubo un error al traer los comentarios del documento"),
                  );
                } else {
                  return _buildCommentsList(commentProvider.comments);
                }
              },
            ),
            _buildDivider(),
            _buildCommentInput(userProvider.user.name),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: simon_finalPrimaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "Chat",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
      ),
    );
  }

  Widget _buildCommentsList(List<CommentModel> commentsByDocumentId) {
    return Expanded(
      child: commentsByDocumentId.isEmpty
          ? const Center(
              child: Text(textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,"No hay comentarios asociados para este documento."))
          : ListView.builder(
              shrinkWrap: true,
              controller: widget.scrollController,
              itemCount: commentsByDocumentId.length,
              itemBuilder: (context, index) {
                final comment = commentsByDocumentId[index];
                return _containerComment(comment, index);
              },
            ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[400]!,
      thickness: 5,
      endIndent: 10,
      indent: 10,
    );
  }

  Widget _buildCommentInput(String userName) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          if (_parentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Respondiendo...",
                style: TextStyle(
                    color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _commentController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: white_color,
                    hintText: "Escribe un comentario...",
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: bgColor, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                  ),
                  onSubmitted: (value) {
                    final commentPost = CommentModelDtoRequest(
                      user_id: userProvider.user.id,
                      profile_id: userProvider.currentProfile,
                      document_id: widget.documentId,
                      comment: value,
                    );
                    _createComment(
                      commentPost,
                      widget.documentId,
                    );

                    _focusNode.unfocus();
                  },
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.send, color: simon_finalPrimaryColor),
                  onPressed: () {
                    final commentPost = CommentModelDtoRequest(
                      user_id: userProvider.user.id,
                      profile_id: userProvider.currentProfile,
                      document_id: widget.documentId,
                      comment: _commentController.text,
                      parent_id: null,
                    );
                    _createComment(commentPost, widget.documentId);

                    _focusNode.unfocus();
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _containerComment(CommentModel comment, index) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String getFormattedDate(DateTime date) {
  final adjustedDate = date.subtract(const Duration(hours: 5)); // Restar 5 horas
  final timeAgo = timeago.format(adjustedDate, locale: 'es');
  final formattedTime = DateFormat('hh:mm a').format(adjustedDate);
  return "$timeAgo · $formattedTime";
}

    return GestureDetector(
      onLongPress: (){
        if(comment.userId == userProvider.user.id && comment.profileId == userProvider.currentProfile){
          _showOptionsModal(comment, index, widget.documentId,userProvider.currentProfile);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? simonGris : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${comment.user.name} ",
                    style: TextStyle(fontWeight: FontWeight.bold,color: appStore.isDarkMode ? Colors.black : Colors.black)),
                Text(getFormattedDate(comment.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Text(comment.comment ?? "",style: TextStyle(color: appStore.isDarkMode ? Colors.black : Colors.black),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () {
                  debugPrint("Tap de Responder");
                  _replyToComment(comment.id);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Responder",
                    style: TextStyle(color: Colors.grey[600]!),
                  ),
                ),
              ),
              if (comment.children.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _toggleReplies(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Ver ${comment.children.length} respuestas",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
            ]),
            if (_expandedComments
                .contains(index)) // Mostrar respuestas expandidas
              Column(
                children: comment.children
                    .map((reply) => _containerComment(
                        reply, -1)) // -1 para evitar conflictos de índice
                    .toList(),
              ).paddingLeft(3),
          ],
        ),
      ).paddingSymmetric(horizontal: 8, vertical: 8),
    );
  }

  Widget _secondContainerComment(CommentModel comment, int index) {

    String getFormattedDate(DateTime date) {
      final timeAgo = timeago.format(date, locale: 'es');
      final formattedTime = DateFormat('hh:mm a').format(date);
      return "$timeAgo · $formattedTime";
    } 
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return GestureDetector(
      onLongPress: () => _showOptionsModal(comment, index, widget.documentId,userProvider.currentProfile),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(comment.userId.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Text(getFormattedDate(comment.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Text(
              comment.comment ?? "",
              style: const TextStyle(),
            ),
            if (comment.children.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _toggleReplies(index);
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Ver ${comment.children.length} respuestas",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            if (_expandedComments
                .contains(index)) // Mostrar respuestas expandidas
              Column(
                children: comment.children
                    .map((reply) => _containerComment(
                        reply, -1)) // -1 para evitar conflictos de índice
                    .toList(),
              ),
          ],
        ),
      ).paddingSymmetric(horizontal: 8, vertical: 8),
    );
  }

  void _showOptionsModal(CommentModel comment, int index, int documentId,int profileId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Ionicons.create_outline, color: Colors.blue),
              title: const Text("Editar"),
              onTap: () {
                Navigator.pop(context);
                _editComment(index, comment,profileId);
              },
            ),
            ListTile(
              leading:
                  const Icon(Ionicons.trash_bin_outline, color: Colors.red),
              title: const Text("Eliminar"),
              onTap: () {
                //Navigator.pop(context);
                _deleteCommentById(comment.id, documentId,comment.userId);
              },
            ),
          ],
        );
      },
    );
  }

  void _editComment(int index, CommentModel comment,int profileId) {
    TextEditingController editController =
        TextEditingController(text: comment.comment);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar comentario"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Editar mensaje..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _updateComment(
                    comment.id, editController.text, widget.documentId,comment.userId,profileId);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
