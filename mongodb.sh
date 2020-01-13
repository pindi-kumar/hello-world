#! /bin/bash
echo " start build"


mvn clean package

#echo "BUILD_TAG" :: $BUILD_TAG
#echo "EXECUTOR_NUMBER" :: $EXECUTOR_NUMBER
#echo "NODE_NAME" :: $NODE_NAME

#echo "WORKSPACE" :: $WORKSPACE
#echo "JENKINS_HOME" :: $JENKINS_HOME
#echo "JENKINS_URL" :: $JENKINS_URL
#echo "BUILD_URL" ::$BUILD_URL
#echo "commit_id: $GIT_COMMIT "
#echo "branch name:: $GIT_BRANCH" 
#echo "GIT_AUTHOR_EMAIL :: $GIT_AUTHOR_EMAIL"
nbr1=$BUILD_TAG
nbr2=$NODE_NAME
nbr3=$WORKSPACE
nbr4=$GIT_COMMIT 
nbr5=$GIT_BRANCH
nbr6=$GIT_AUTHOR_EMAIL

mongo  --host="13.126.34.139:27017"  build   <<EOF
var build_tag ="$nbr1" ;
var node_name ="$nbr2" ;
var workspace ="$nbr3" ;
var git_commit ="$nbr4" ;
var git_branch ="$nbr5" ;
var git_author_email ="$nbr6" ;
db.ci_build.insert(
	{
		BUILD_TAG: build_tag,
		NODE_NAME: node_name,
		WORKSPACE: workspace,
		GIT_COMMIT: git_commit,
		GIT_BRANCH: git_branch,
		GIT_AUTHOR_EMAIL: git_author_email
	}
 );
db.ci_build.find().pretty()

EOF






