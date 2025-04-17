<template>
  <div class="p-8">
    <div class="flex items-center gap-4 mb-6">
      <button
        @click="router.push('/forms')"
        class="text-gray-600 hover:text-gray-900"
      >
        <ArrowLeftIcon class="w-6 h-6" />
      </button>
      <div>
        <h1 class="text-2xl font-bold text-gray-900">{{ form?.name }} Analytics</h1>
        <p class="text-sm text-gray-500 mt-1">Track form performance and submission trends</p>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-8">
      <LoaderIcon class="w-8 h-8 animate-spin text-green-600" />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
      {{ error }}
    </div>

    <!-- Analytics Dashboard -->
    <div v-else class="space-y-6">
      <!-- Key Metrics -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-2 bg-green-50 rounded-lg">
              <ClipboardCheckIcon class="w-6 h-6 text-green-600" />
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Total Submissions</p>
              <p class="text-2xl font-semibold text-gray-900">{{ metrics.totalSubmissions }}</p>
            </div>
          </div>
          <div class="mt-4">
            <div class="flex items-center text-sm">
              <TrendingUpIcon 
                v-if="metrics.submissionTrend > 0"
                class="w-4 h-4 text-green-500 mr-1"
              />
              <TrendingDownIcon
                v-else
                class="w-4 h-4 text-red-500 mr-1"
              />
              <span :class="metrics.submissionTrend > 0 ? 'text-green-600' : 'text-red-600'">
                {{ Math.abs(metrics.submissionTrend) }}% from last period
              </span>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-2 bg-blue-50 rounded-lg">
              <TimerIcon class="w-6 h-6 text-blue-600" />
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Avg. Completion Time</p>
              <p class="text-2xl font-semibold text-gray-900">{{ metrics.avgCompletionTime }}s</p>
            </div>
          </div>
          <div class="mt-4">
            <div class="text-sm text-gray-500">
              Based on last {{ metrics.totalSubmissions }} submissions
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-2 bg-purple-50 rounded-lg">
              <UsersIcon class="w-6 h-6 text-purple-600" />
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Unique Submitters</p>
              <p class="text-2xl font-semibold text-gray-900">{{ metrics.uniqueSubmitters }}</p>
            </div>
          </div>
          <div class="mt-4">
            <div class="text-sm text-gray-500">
              {{ ((metrics.uniqueSubmitters / metrics.totalSubmissions) * 100).toFixed(1) }}% of total submissions
            </div>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
          <div class="flex items-center">
            <div class="p-2 bg-yellow-50 rounded-lg">
              <ActivityIcon class="w-6 h-6 text-yellow-600" />
            </div>
            <div class="ml-4">
              <p class="text-sm font-medium text-gray-500">Completion Rate</p>
              <p class="text-2xl font-semibold text-gray-900">{{ metrics.completionRate }}%</p>
            </div>
          </div>
          <div class="mt-4">
            <div class="text-sm text-gray-500">
              Of form views resulted in submissions
            </div>
          </div>
        </div>
      </div>

      <!-- Submission Timeline -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Submission Timeline</h3>
        <div class="h-64">
          <!-- Add chart here using a charting library -->
          <div class="flex items-center justify-center h-full text-gray-500">
            Chart placeholder - Implement with your preferred charting library
          </div>
        </div>
      </div>

      <!-- Field Analysis -->
      <div class="bg-white rounded-lg shadow p-6">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Field Analysis</h3>
        <div class="space-y-4">
          <div v-for="field in fieldAnalysis" :key="field.label" class="border-b border-gray-200 pb-4">
            <div class="flex justify-between items-center mb-2">
              <h4 class="text-sm font-medium text-gray-700">{{ field.label }}</h4>
              <span class="text-sm text-gray-500">{{ field.completionRate }}% completion rate</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-green-600 h-2 rounded-full"
                :style="{ width: `${field.completionRate}%` }"
              ></div>
            </div>
            <div v-if="field.type === 'select'" class="mt-2">
              <p class="text-sm text-gray-500 mb-2">Popular choices:</p>
              <div class="space-y-1">
                <div
                  v-for="(count, option) in field.optionCounts"
                  :key="option"
                  class="flex justify-between text-sm"
                >
                  <span class="text-gray-600">{{ option }}</span>
                  <span class="text-gray-500">{{ count }} responses</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-medium text-gray-900">Recent Activity</h3>
        </div>
        <ul class="divide-y divide-gray-200">
          <li v-for="activity in recentActivity" :key="activity.id" class="p-6">
            <div class="flex items-center">
              <div
                class="flex-shrink-0 h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center"
              >
                <UserIcon class="h-6 w-6 text-gray-500" />
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-900">
                  {{ activity.submitter_name }}
                </p>
                <p class="text-sm text-gray-500">
                  Submitted {{ formatDate(activity.created_at) }}
                </p>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { supabase } from '../lib/supabase';
import { format, subDays } from 'date-fns';
import {
  ArrowLeftIcon,
  LoaderIcon,
  ClipboardCheckIcon,
  TimerIcon,
  UsersIcon,
  ActivityIcon,
  TrendingUpIcon,
  TrendingDownIcon,
  UserIcon,
} from 'lucide-vue-next';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();

const loading = ref(false);
const error = ref(null);
const form = ref(null);
const metrics = ref({
  totalSubmissions: 0,
  submissionTrend: 0,
  avgCompletionTime: 0,
  uniqueSubmitters: 0,
  completionRate: 0
});
const fieldAnalysis = ref([]);
const recentActivity = ref([]);

const fetchAnalytics = async () => {
  loading.value = true;
  try {
    // Fetch form details
    const { data: formData, error: formError } = await supabase
      .from('forms')
      .select('*')
      .eq('id', route.params.id)
      .single();

    if (formError) throw formError;
    form.value = formData;

    // Fetch submissions for analysis
    const { data: submissions, error: submissionsError } = await supabase
      .from('form_submissions')
      .select(`
        *,
        users!submitted_by (
          profiles (
            full_name
          )
        ),
        public_submitters!form_submissions_public_submitter_id_fkey (
          name
        )
      `)
      .eq('form_id', route.params.id)
      .order('created_at', { ascending: false });

    if (submissionsError) throw submissionsError;

    // Calculate metrics
    const totalSubmissions = submissions.length;
    const previousPeriodSubmissions = submissions.filter(s => 
      new Date(s.created_at) > subDays(new Date(), 14) &&
      new Date(s.created_at) <= subDays(new Date(), 7)
    ).length;
    const currentPeriodSubmissions = submissions.filter(s => 
      new Date(s.created_at) > subDays(new Date(), 7)
    ).length;

    const submissionTrend = previousPeriodSubmissions === 0 ? 100 :
      ((currentPeriodSubmissions - previousPeriodSubmissions) / previousPeriodSubmissions) * 100;

    const uniqueSubmitters = new Set([
      ...submissions.filter(s => s.submitted_by).map(s => s.submitted_by),
      ...submissions.filter(s => s.public_submitter_id).map(s => s.public_submitter_id)
    ]).size;

    metrics.value = {
      totalSubmissions,
      submissionTrend: Math.round(submissionTrend),
      avgCompletionTime: 45, // This would need to be calculated based on actual tracking data
      uniqueSubmitters,
      completionRate: 85 // This would need to be calculated based on form view tracking
    };

    // Analyze fields
    fieldAnalysis.value = form.value.fields.map(field => {
      const fieldResponses = submissions.map(s => s.data[field.label]).filter(Boolean);
      const completionRate = (fieldResponses.length / totalSubmissions) * 100;

      let analysis = {
        label: field.label,
        type: field.type,
        completionRate: Math.round(completionRate)
      };

      if (field.type === 'select') {
        const optionCounts = fieldResponses.reduce((acc, value) => {
          acc[value] = (acc[value] || 0) + 1;
          return acc;
        }, {});
        analysis.optionCounts = optionCounts;
      }

      return analysis;
    });

    // Get recent activity
    recentActivity.value = submissions.slice(0, 5).map(submission => ({
      id: submission.id,
      submitter_name: submission.users?.profiles?.full_name || submission.public_submitters?.name || 'Anonymous',
      created_at: submission.created_at
    }));

  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
};

const formatDate = (date: string) => {
  return format(new Date(date), 'MMM d, yyyy h:mm a');
};

onMounted(fetchAnalytics);
</script>