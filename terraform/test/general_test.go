package test

import (
    "regexp"
    "strconv"
    "strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

func TestTerraform(t *testing.T) {
    t.Parallel()

    project_id := "AB-utopia"
    region := "us-west-2"
    variables := map[string]interface{} {
        "region":                 region,
        "project_id":             project_id,
        "environment":            "dev",
        "vpc_cidr_block":         "10.0.0.0/16",
        "num_availability_zones": 2,
        "domain":                 "hitwc.link",
        "s3_bucket":              strings.ToLower(project_id),
        "subdomain_prefix":       strings.ToLower(project_id),
    }

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "..",
        Vars: variables,
	})

	defer terraform.Destroy(t, options)

	terraform.InitAndApply(t, options)

    // Verify returned variables are accurate
	domain := terraform.Output(t, options, "domain")
	assert.Equal(t, variables["domain"], domain)
	subdomain_prefix := terraform.Output(t, options, "subdomain_prefix")
	assert.Equal(t, variables["subdomain_prefix"], subdomain_prefix)
    num_availability_zones, _ := strconv.Atoi(terraform.Output(t, options, "num_availability_zones"))
	assert.Equal(t, variables["num_availability_zones"], num_availability_zones)

    // Verify number of expected subnets
	nat_private_subnet_ids := terraform.OutputList(t, options, "nat_private_subnet_ids")
	assert.Equal(t, variables["num_availability_zones"], len(nat_private_subnet_ids))
	private_subnet_ids := terraform.OutputList(t, options, "private_subnet_ids")
	assert.Equal(t, variables["num_availability_zones"], len(private_subnet_ids))
	public_subnet_ids := terraform.OutputList(t, options, "public_subnet_ids")
	assert.Equal(t, variables["num_availability_zones"], len(public_subnet_ids))

    // Verify subnet and vpc id formatting
    subnet_regex := regexp.MustCompile("^subnet-[0-9a-fA-F]{17}$")
    for _, nat_private_subnet_id := range nat_private_subnet_ids {
        assert.True(t, subnet_regex.Match([]byte(string(nat_private_subnet_id))))
        assert.False(t, aws.IsPublicSubnet(t, nat_private_subnet_id, region))
    }
    for _, private_subnet_id := range private_subnet_ids {
        assert.True(t, subnet_regex.Match([]byte(string(private_subnet_id))))
        assert.False(t, aws.IsPublicSubnet(t, private_subnet_id, region))
    }
    for _, public_subnet_id := range public_subnet_ids {
        assert.True(t, subnet_regex.Match([]byte(string(public_subnet_id))))
        assert.True(t, aws.IsPublicSubnet(t, public_subnet_id, region))
    }
	vpc_id := terraform.Output(t, options, "vpc_id")
    vpc_regex := regexp.MustCompile("^vpc-[0-9a-fA-F]{17}$")
    assert.True(t, vpc_regex.Match([]byte(string(vpc_id))))
}
