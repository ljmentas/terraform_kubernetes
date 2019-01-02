/*
resource "aws_iam_role" "ec2_redis_sqs_access_role" {
  name               = "ec2_redis_sqs_access_role"
  assume_role_policy = "${file("assumerolepolicy.json")}"
}


resource "aws_iam_instance_profile" "test_profile" {
  name  = "test_profile"
  roles = ["${aws_iam_role.ec2_redis_sqs_access_role.name}"]
}
*/

resource "aws_iam_policy" "policy" {
  name        = "policy"
  description = "A test policy"
  policy      = "${file("policysqsredis.json")}"
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.demo-node.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}
