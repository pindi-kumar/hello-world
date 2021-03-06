#!/bin/bash

 CI_BUILD  ( ) {
   
   echo " start build"

   mvn package ;

   exitstatus=$?

if [ $exitstatus == 0 ] ;
  then
    echo " send the details to mongodb"
        nbr1=$BUILD_TAG
        nbr2=$NODE_NAME
        nbr3=$WORKSPACE
        nbr4=$GIT_COMMIT 
        nbr5=$GIT_BRANCH 

      mongo  --host="15.206.169.239:27017"  build   <<EOF 
      var build_tag ="$nbr1" ;
      var node_name ="$nbr2" ;
      var workspace ="$nbr3" ;
      var git_commit ="$nbr4" ;
      var git_branch ="$nbr5" ;
      db.ci_build.insert([
        {
                BUILD_TAG: build_tag,
                NODE_NAME: node_name,
                WORKSPACE: workspace,
                GIT_COMMIT: git_commit,
                GIT_BRANCH: git_branch,
        }]
       );
           db.ci_build.find().sort({_id:-1}).limit(1).pretty() ;
EOF
   else
      echo " "
      echo " build failure##########*****************#############"
fi


}

NIGHTLY_BUILD ( ) {

     mongo  --host="15.206.169.239:27017"   build    <<EOF > nigtly_commitid.txt
     db.nightly_build.find().sort({_id:-1}).limit(1).pretty() ;

EOF

    mongo  --host="15.206.169.239:27017"   build    <<EOF > ci_commitid.txt
     db.ci_build.find().sort({_id:-1}).limit(1).pretty() ;

EOF

cib=$(cat ci_commitid.txt | grep -i git_commit | awk -F ":" '{ print $2 }')
echo " "
echo "last success commit id of CI-BUILD:::::$cib#######"
echo " "
nib=$(cat nigtly_commitid.txt | grep -i git_commit | awk -F ":" '{ print $2 }' )
echo " "
echo "last success commit id of NIGHTLY-BUILD:::::$nib####"
echo " "

if [ $nib != $cib ] ;
  then
  	mvn clean package ;
  	exitstatus=$?
    if [ $exitstatus == 0 ] ;
      then
  	    echo " send the details to mongodb"
          nbr1=$build_tag
          nbr2=$NODE_NAME
          nbr3=$WORKSPACE
          nbr4=$GIT_COMMIT
          nbr5=$GIT_BRANCH

        mongo  --host="15.206.169.239:27017"  build   <<EOF > ci_commitid.txt
        var build_tag ="$nbr1" ;
        var node_name ="$nbr2" ;
        var workspace ="$nbr3" ;
        var git_commit ="$nbr4" ;
        var git_branch ="$nbr5" ;
        db.nightly_build.insert([
           {
                BUILD_TAG: build_tag,
                NODE_NAME: node_name,
                WORKSPACE: workspace,
                GIT_COMMIT: git_commit,
                GIT_BRANCH: git_branch,
            }]
            );
           db.nightly_build.find().sort({_id:-1}).limit(1).pretty() ;
EOF
       else 
    	      echo "nightly build failure############************################"
    fi
  else
  	echo "build halt bcz of same commit-id"
fi
}
if [ $1 == CI_BUILD ] ;
  then
     echo "calling the CI-BUILD....."
      CI_BUILD
  else
     echo "calling the nightly-build....."
     NIGHTLY_BUILD
fi

