#!/bin/bash

# GitHub Actions Workflow Debug Helper
# Provides debugging information and logs for workflow troubleshooting
# Usage: ./debug-workflow-issues.sh [workflow_name]

set -euo pipefail

WORKFLOW_NAME="${1:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

log_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

main() {
    log "GitHub Actions Workflow Debug Helper"
    log "Debug analysis started at $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
    
    if [[ -n "$WORKFLOW_NAME" ]]; then
        debug_specific_workflow "$WORKFLOW_NAME"
    else
        debug_all_workflows
    fi
    
    analyze_common_issues
    provide_debugging_tips
    
    log_success "Workflow debugging analysis completed"
}

debug_specific_workflow() {
    local workflow="$1"
    log_section "Debugging Workflow: $workflow"
    
    local workflow_file=".github/workflows/${workflow}"
    if [[ ! -f "$workflow_file" ]]; then
        # Try with .yml extension
        workflow_file="${workflow_file}.yml"
        if [[ ! -f "$workflow_file" ]]; then
            log_error "Workflow file not found: $workflow"
            return 1
        fi
    fi
    
    log "Analyzing workflow file: $workflow_file"
    
    # Check YAML syntax
    if command -v python3 >/dev/null 2>&1; then
        # Capture both stdout and stderr
        local yaml_output
        if yaml_output=$(python3 -c "import yaml; yaml.safe_load(open('$workflow_file'))" 2>&1); then
            log_success "YAML syntax is valid"
        else
            log_error "YAML syntax errors detected"
            echo "$yaml_output" | head -5
        fi
    fi
    
    # Analyze triggers
    echo ""
    log "Workflow triggers:"
    
    # Stage 1: Extract trigger section
    trigger_lines=$(grep -A 10 "^on:" "$workflow_file" 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            echo "      WARNING: No triggers found in workflow" >&2
            trigger_lines=""
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow file" >&2
            return 1
        else
            echo "      ERROR: grep failed with exit code $exit_code" >&2
            return 1
        fi
    }
    
    # Stage 2: Display trigger configuration
    if [ -n "$trigger_lines" ]; then
        echo "$trigger_lines" | head -10
    else
        echo "      No triggers configured"
    fi
    
    # Analyze jobs
    echo ""
    log "🔄 Jobs configured:"
    
    # Stage 1: Extract job definitions
    job_lines=$(grep "^  [a-zA-Z].*:$" "$workflow_file" 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            echo "      WARNING: No jobs found in workflow" >&2
            job_lines=""
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow file" >&2
            return 1
        else
            echo "      ERROR: grep failed with exit code $exit_code" >&2
            return 1
        fi
    }
    
    # Stage 2: Format and display jobs
    if [ -n "$job_lines" ]; then
        echo "$job_lines" | sed 's/:$//' | sed 's/^  /   • /'
    else
        echo "      No jobs configured"
    fi
    
    # Look for potential issues
    echo ""
    log "Potential issues check:"
    check_workflow_issues "$workflow_file"
}

debug_all_workflows() {
    log_section "Debugging All Workflows"
    
    local workflow_dir=".github/workflows"
    
    for workflow in "$workflow_dir"/*.yml; do
        if [[ -f "$workflow" ]]; then
            local filename=$(basename "$workflow")
            echo ""
            log "Checking: $filename"
            
            # Quick YAML validation
            if command -v python3 >/dev/null 2>&1; then
                if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
                    log_success "Valid YAML"
                else
                    log_error "Invalid YAML"
                fi
            fi
            
            # Check for common patterns
            local has_caching has_logging
            
            # Stage 1: Count cache actions
            cache_lines=$(grep "uses: actions/cache@" "$workflow" 2>&1) || {
                exit_code=$?
                if [ $exit_code -eq 1 ]; then
                    # No matches
                    has_caching=0
                elif [ $exit_code -eq 2 ]; then
                    echo "      ERROR: Cannot read workflow" >&2
                    has_caching=0
                else
                    echo "      ERROR: grep failed (exit code $exit_code)" >&2
                    has_caching=0
                fi
            }
            
            if [ -n "${cache_lines:-}" ]; then
                has_caching=$(echo "$cache_lines" | wc -l | xargs)
            else
                has_caching=0
            fi
            
            # Stage 2: Count debug logging
            log_lines=$(grep "echo.*::" "$workflow" 2>&1) || {
                exit_code=$?
                if [ $exit_code -eq 1 ]; then
                    # No matches
                    has_logging=0
                elif [ $exit_code -eq 2 ]; then
                    echo "      ERROR: Cannot read workflow" >&2
                    has_logging=0
                else
                    echo "      ERROR: grep failed (exit code $exit_code)" >&2
                    has_logging=0
                fi
            }
            
            if [ -n "${log_lines:-}" ]; then
                has_logging=$(echo "$log_lines" | wc -l | xargs)
            else
                has_logging=0
            fi
            
            echo "   • Caches: $has_caching"
            echo "   • Debug logging: $has_logging"
        fi
    done
}

check_workflow_issues() {
    local workflow_file="$1"
    
    # Check for missing checkout
    if ! grep -q "uses: actions/checkout@" "$workflow_file"; then
        log_warning "No checkout action found - may cause issues accessing repository"
    fi
    
    # Check for hardcoded versions
    echo "    Checking for outdated action versions..." >&2
    
    # Stage 1: Search for old version patterns
    version_lines=$(grep -E "uses: .+@v[1-2]($|[^0-9])" "$workflow_file" 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            # No matches - good!
            outdated_versions=0
            version_lines=""
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow file" >&2
            outdated_versions=0
            version_lines=""
        else
            echo "      ERROR: grep failed with exit code $exit_code" >&2
            outdated_versions=0
            version_lines=""
        fi
    }
    
    # Stage 2: Count and display outdated versions
    if [ -n "$version_lines" ]; then
        outdated_versions=$(echo "$version_lines" | wc -l | xargs)
        log_warning "Found $outdated_versions potentially outdated action versions"
        echo "$version_lines" | sed 's/^/   /'
    else
        outdated_versions=0
    fi
    
    # Check for missing error handling
    echo "    Checking for error handling..." >&2
    
    # Stage 1: Check for failure handlers
    failure_handlers=$(grep "if: failure()" "$workflow_file" 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            # No failure handlers
            failure_handlers=""
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow file" >&2
            failure_handlers=""
        else
            failure_handlers=""
        fi
    }
    
    # Stage 2: Check for always handlers
    always_handlers=$(grep "if: always()" "$workflow_file" 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            # No always handlers
            always_handlers=""
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow file" >&2
            always_handlers=""
        else
            always_handlers=""
        fi
    }
    
    # Stage 3: Report findings
    if [ -z "$failure_handlers" ] && [ -z "$always_handlers" ]; then
        log_warning "No error handling steps found - consider adding cleanup steps"
    fi
    
    # Check for secrets usage
    echo "    Checking for secrets usage..." >&2
    
    # Stage 1: Search for secrets references
    secrets_lines=$(grep "secrets\." "$workflow_file" 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            # No secrets used
            secrets_count=0
            secrets_lines=""
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow file" >&2
            secrets_count=0
            secrets_lines=""
        else
            echo "      ERROR: grep failed with exit code $exit_code" >&2
            secrets_count=0
            secrets_lines=""
        fi
    }
    
    # Stage 2: Count secrets
    if [ -n "$secrets_lines" ]; then
        secrets_count=$(echo "$secrets_lines" | wc -l | xargs)
        log "Uses $secrets_count secret(s) - ensure they're configured in repository settings"
    else
        secrets_count=0
    fi
    
    # Check for cache usage without restore-keys
    echo "    Checking cache configuration..." >&2
    
    # Stage 1: Check if cache is used
    cache_usage=$(grep "uses: actions/cache@" "$workflow_file" 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            # No cache used - skip restore-keys check
            cache_usage=""
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow file" >&2
            cache_usage=""
        else
            cache_usage=""
        fi
    }
    
    # Stage 2: If cache is used, check for restore-keys
    if [ -n "$cache_usage" ]; then
        restore_keys=$(grep "restore-keys:" "$workflow_file" 2>&1) || {
            exit_code=$?
            if [ $exit_code -eq 1 ]; then
                # No restore-keys found
                log_warning "Cache configured without restore-keys - may miss cache hits"
            elif [ $exit_code -eq 2 ]; then
                echo "      ERROR: Cannot check for restore-keys" >&2
            fi
        }
    fi
}

analyze_common_issues() {
    log_section "Common Issues Analysis"
    
    log "Checking for common workflow problems..."
    
    # Check for ACTIONS_RUNNER_DEBUG usage
    if grep -r "ACTIONS_RUNNER_DEBUG" .github/workflows/ >/dev/null 2>&1; then
        log_success "ACTIONS_RUNNER_DEBUG is configured for enhanced debugging"
    else
        log_warning "ACTIONS_RUNNER_DEBUG not set - consider enabling for debugging"
    fi
    
    # Check for workflow concurrency
    echo "    Checking workflow features..." >&2
    
    # Stage 1: Count concurrency configurations
    concurrency_lines=$(grep "concurrency:" .github/workflows/*.yml 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            concurrency_configs=0
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow files" >&2
            concurrency_configs=0
        else
            concurrency_configs=0
        fi
    }
    
    if [ -n "${concurrency_lines:-}" ]; then
        concurrency_configs=$(echo "$concurrency_lines" | wc -l | xargs)
    else
        concurrency_configs=0
    fi
    log "Concurrency configurations: $concurrency_configs workflows"
    
    # Stage 2: Count matrix strategies
    matrix_lines=$(grep "strategy:" .github/workflows/*.yml 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            matrix_configs=0
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow files" >&2
            matrix_configs=0
        else
            matrix_configs=0
        fi
    }
    
    if [ -n "${matrix_lines:-}" ]; then
        matrix_configs=$(echo "$matrix_lines" | wc -l | xargs)
    else
        matrix_configs=0
    fi
    log "Matrix strategies: $matrix_configs workflows"
    
    # Stage 3: Count conditional steps
    conditional_lines=$(grep "if:" .github/workflows/*.yml 2>&1) || {
        exit_code=$?
        if [ $exit_code -eq 1 ]; then
            conditional_steps=0
        elif [ $exit_code -eq 2 ]; then
            echo "      ERROR: Cannot read workflow files" >&2
            conditional_steps=0
        else
            conditional_steps=0
        fi
    }
    
    if [ -n "${conditional_lines:-}" ]; then
        conditional_steps=$(echo "$conditional_lines" | wc -l | xargs)
    else
        conditional_steps=0
    fi
    log "Conditional steps: $conditional_steps total"
}

provide_debugging_tips() {
    log_section "Debugging Tips & Best Practices"
    
    echo "Debugging Tips:"
    echo ""
    echo "1. Enable Debug Logging:"
    echo "   • Set ACTIONS_RUNNER_DEBUG=true in repository variables"
    echo "   • Add echo statements with ::group:: and ::endgroup::"
    echo ""
    echo "2. Monitor Performance:"
    echo "   • Use cache hit/miss reporting"
    echo "   • Add timing information to long-running steps"
    echo "   • Monitor job duration trends"
    echo ""
    echo "3. Test Locally:"
    echo "   • Use act to run workflows locally: brew install act"
    echo "   • Test individual scripts before adding to workflows"
    echo ""
    echo "4. Error Handling:"
    echo "   • Add 'if: failure()' steps for cleanup"
    echo "   • Use 'if: always()' for critical cleanup steps"
    echo "   • Set appropriate timeouts for long-running jobs"
    echo ""
    echo "5. Troubleshooting Checklist:"
    echo "   • Check YAML syntax with: python3 -c \"import yaml; yaml.safe_load(open('file.yml'))\""
    echo "   • Verify action versions are up to date"
    echo "   • Ensure secrets are properly configured"
    echo "   • Test cache keys for uniqueness and invalidation"
    echo "   • Check workflow file permissions and triggers"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi