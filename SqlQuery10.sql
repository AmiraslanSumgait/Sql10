Create PROCEDURE AddCommentMark
	@comid AS int,
	@userid AS int,
	@mark AS int
AS
BEGIN
	BEGIN TRAN CommentMark

	INSERT INTO CommentRating(IdComment, IdUser, Mark)
	VALUES (@comid, @userid, @mark)
	IF(@@ERROR != 0)
	BEGIN
		PRINT 'Error in insertion'
		ROLLBACK TRAN CommentMark
	END
	ELSE
	BEGIN
		PRINT 'Insert is okay'
		UPDATE Comments
		SET Rating = (
			SELECT CAST(SUM(Mark) AS float) / COUNT(*)
			FROM Comments INNER JOIN CommentRating
			ON Comments.Id = CommentRating.IdComment
			WHERE  Comments.Id = @comid
		)
		WHERE  Comments.Id = @comid

		DECLARE @iduser int=0;
		SELECT @iduser=IdUser FROM Comments
		WHERE Id=@comid

		UPDATE Users
		SET Rating=
		(
		   ((SELECT SUM(Comments.Rating) FROM Comments
		   WHERE Comments.IdUser=@iduser)+
		   (SELECT SUM(Posts.Rating)FROM Posts
		   WHERE Posts.IdUser=@iduser))/2
		)
		WHERE Users.Id=@iduser

		IF(@@ERROR != 0)
		BEGIN
			PRINT 'Error in  update'
			ROLLBACK TRAN CommentMark
		END
		ELSE
		BEGIN
		PRINT 'Update is  okay '
			COMMIT TRAN CommentMark
		END
	END

END


EXEC AddCommentMark 4,2,5


CREATE PROCEDURE AddPostMark
	@postid AS int,
	@userid AS int,
	@mark AS int
AS
BEGIN
	BEGIN TRAN PostMark

	INSERT INTO PostRating(IdPost, IdUser, Mark)
	VALUES (@postid, @userid, @mark)

	IF(@@ERROR != 0)
	BEGIN
		PRINT 'Error in insertion'
		ROLLBACK TRAN PostMark
	END
	ELSE
	BEGIN
		PRINT 'Insert is  okay'
		UPDATE Posts
		SET Rating = (
			SELECT CAST(SUM(Mark) AS float) / COUNT(*)
			FROM Posts INNER JOIN PostRating
			ON Posts.Id = PostRating.IdPost
			WHERE  Posts.Id = @postid
		)
		WHERE  Posts.Id = @postid

		DECLARE @iduser int=0;
		SELECT @iduser=IdUser FROM Comments
		WHERE Id=@postid

		UPDATE Users
		SET Rating=
		(
		   ((SELECT SUM(Comments.Rating) FROM Comments
		   WHERE Comments.IdUser=@iduser)+
		   (SELECT SUM(Posts.Rating)FROM Posts
		   WHERE Posts.IdUser=@iduser))/2
		)
		WHERE Users.Id=@iduser

		IF(@@ERROR != 0)
		BEGIN
			PRINT 'Error in  updation'
			ROLLBACK TRAN PostMark
		END
		ELSE
		BEGIN
		PRINT 'update ok '
			COMMIT TRAN PostMark
		END
	END

END

EXEC AddPostMark 2,3,5