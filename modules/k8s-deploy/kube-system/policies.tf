resource "aws_iam_policy" "asg_policy" {
  name = "${var.cluster-name}-worker-policy"

  policy = file("${path.module}/policies/asg-policy.json")
}

resource "aws_iam_role_policy_attachment" "kube-system-ASG-Policy-For-Worker" {
  policy_arn = aws_iam_policy.asg_policy.arn
  role       = aws_iam_role.kube-system.name
}

resource "aws_iam_role_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  role   = aws_iam_role.kube-system.id
  policy = file("${path.module}/policies/awsloadbalancecontroler.json")
}
