@Posts = new Meteor.Collection 'posts'

Posts.allow
	update: ownsDocument
	remove: ownsDocument

Posts.deny
	update: (userId,post,fieldNames) ->
		_.without(fieldNames, 'url', 'title').length > 0

Meteor.methods
	post: (postAttributes) ->
		user = Meteor.user()
		postWithSameLink = Posts.findOne
			url: postAttributes.url

		if !user
			throw new Meteor.Error 401, 'You need to be logged in'

		if !postAttributes.title
			throw new Meteor.Error 422, 'Please fill in a headline'

		if postAttributes.url and postWithSameLink
			throw new Meteor.Error 302, 'This link is a duplicate', postWithSameLink._id

		post = _.extend _.pick(postAttributes, 'url', 'title', 'message'),
				userId: user._id
				author: user.username
				submitted: new Date().getTime()
				commentsCount: 0
				upvoters: []
				votes: 0

		postId = Posts.insert post

		return postId

	upvote: (postId) ->
		user = Meteor.user()

		if !user
			throw new Meteor.Error 401, 'You need to be logged in'

		post = Posts.findOne postId

		if !post
			throw new Meteor.Error 422, 'Post not found'

		if _.contains post.upvoters, user._id
			throw new Meteor.Error 422, 'Already Upvoted'

		Posts.update {
			_id: postId
			upvoters: {$ne:user._id}
		},
		{
			$addToSet: {upvoters: user._id}
			$inc: {votes: 1}
		}









