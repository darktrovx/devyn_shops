<script>

    export default {
        name: 'category',
        props: {
            category: String,
        },
        data() {
            return {}
        },
        methods: {},
        mounted() {}

    };
</script>

<template>
    <div class="category">
        <p> {{ this.category }} </p>
    </div>
</template>

<style>
    .category {
        color: white;
        text-align: center;
        background-color: var(--dark2);
    }

    .catergory p {
        margin: 0;
    }

</style>