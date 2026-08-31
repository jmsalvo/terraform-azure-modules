// Package test holds the repository's Terratest suite.
//
// Most module testing in this repo is done with native `terraform test`
// (see modules/<name>/tests). This single Go test exists to demonstrate a
// Terratest-based integration check. It targets the naming module's basic
// example, which declares no providers, so it runs in CI without any Azure
// credentials.
package test

import (
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNamingBasicExample(t *testing.T) {
	t.Parallel()

	opts := &terraform.Options{
		TerraformDir: "../modules/naming/examples/basic",
		NoColor:      true,
	}

	defer terraform.Destroy(t, opts)
	terraform.InitAndApply(t, opts)

	names := terraform.OutputMap(t, opts, "names")
	assert.Equal(t, "rg-shop-prod-eus2-001", names["resource_group"])
	assert.Equal(t, "vnet-shop-prod-eus2-001", names["virtual_network"])
	assert.Regexp(t, regexp.MustCompile(`^st[a-z0-9]{1,22}$`), names["storage_account"])

	tags := terraform.OutputMap(t, opts, "tags")
	assert.Equal(t, "terraform", tags["managed_by"])
	assert.Equal(t, "prod", tags["environment"])
	assert.Equal(t, "cc-1234", tags["cost_center"])
	assert.Equal(t, "storefront", tags["application"])

	assert.Equal(t, "rg-shop-prod-eus2-001", terraform.Output(t, opts, "resource_group_name"))
}
